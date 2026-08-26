#!/usr/bin/env bash
# One-time setup, run locally with `az login` already done.
# Creates:
#   1. A storage account to hold Terraform remote state.
#   2. An Azure AD app registration + service principal with federated
#      credentials for GitHub Actions OIDC (no client secret needed).
#
# Usage:
#   GITHUB_REPO="my-org/my-repo" ./infra/scripts/bootstrap.sh
set -euo pipefail

: "${GITHUB_REPO:?Set GITHUB_REPO=owner/repo before running this script}"

SUBSCRIPTION_ID="c0ae4ebe-9b84-4a13-8f45-c7cb699a3630"
LOCATION="swedencentral"
PREFIX="aks-deploy-example"

STATE_RG="rg-${PREFIX}-tfstate"
# Storage account names must be 3-24 lowercase alphanumeric characters.
STATE_SA="st$(echo "${PREFIX//-/}" | cut -c1-13)tfstate"
STATE_CONTAINER="tfstate"
APP_NAME="gha-${PREFIX}"

az account set --subscription "$SUBSCRIPTION_ID"

echo "==> Creating resource group for Terraform state: $STATE_RG"
az group create --name "$STATE_RG" --location "$LOCATION" >/dev/null

echo "==> Creating storage account for Terraform state: $STATE_SA"
az storage account create \
  --name "$STATE_SA" \
  --resource-group "$STATE_RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 >/dev/null

echo "==> Creating blob container: $STATE_CONTAINER"
az storage container create \
  --name "$STATE_CONTAINER" \
  --account-name "$STATE_SA" \
  --auth-mode login >/dev/null

echo "==> Creating Azure AD app registration + service principal: $APP_NAME"
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
az ad sp create --id "$APP_ID" >/dev/null
SP_OBJECT_ID=$(az ad sp show --id "$APP_ID" --query id -o tsv)

echo "==> Granting Contributor on the subscription (required to create the AKS resource group)"
az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" >/dev/null

echo "==> Adding Storage Blob Data Contributor on the state storage account"
az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$STATE_RG/providers/Microsoft.Storage/storageAccounts/$STATE_SA" >/dev/null

echo "==> Creating federated credentials for GitHub OIDC ($GITHUB_REPO)"
az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-main-branch",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'"$GITHUB_REPO"':ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}' >/dev/null

az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-pull-requests",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'"$GITHUB_REPO"':pull_request",
  "audiences": ["api://AzureADTokenExchange"]
}' >/dev/null

TENANT_ID=$(az account show --query tenantId -o tsv)

cat <<EOF

Done. Add these as GitHub Actions repository variables (Settings > Secrets and variables > Actions > Variables):

  AZURE_CLIENT_ID       = $APP_ID
  AZURE_TENANT_ID       = $TENANT_ID
  AZURE_SUBSCRIPTION_ID = $SUBSCRIPTION_ID
  TF_STATE_RG           = $STATE_RG
  TF_STATE_SA           = $STATE_SA
  TF_STATE_CONTAINER    = $STATE_CONTAINER

No client secret is needed — auth uses OIDC federation.
EOF
