This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.

## Deploy to Azure (AKS)

This repo also ships with everything needed to deploy to Azure Kubernetes Service via GitHub Actions + Terraform:

- `infra/` — Terraform for a resource group, Azure Container Registry and AKS cluster.
- `k8s/` — Kubernetes manifests (Deployment + Service, exposed via `LoadBalancer`).
- `Dockerfile` — multi-stage build using Next.js `output: "standalone"`.
- `.github/workflows/terraform.yml` — plans/applies the Terraform on changes under `infra/`.
- `.github/workflows/deploy.yml` — builds the image with ACR Tasks and rolls it out to AKS on every push to `main`.

### One-time setup

1. Run `az login` locally, then:
   ```bash
   GITHUB_REPO="<owner>/<repo>" ./infra/scripts/bootstrap.sh
   ```
   This creates the Terraform state storage account and a GitHub OIDC app registration (no client secret required).
2. Add the values printed by the script as **repository variables** (Settings → Secrets and variables → Actions → Variables): `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `TF_STATE_RG`, `TF_STATE_SA`, `TF_STATE_CONTAINER`.
3. Push to `main` — the Terraform workflow provisions the infra, then the deploy workflow builds/pushes the image and applies the k8s manifests.

Azure Subscription ID and region in [infra/variables.tf](infra/variables.tf) and 
[infra/scripts/bootstrap.sh](infra/scripts/bootstrap.sh)
