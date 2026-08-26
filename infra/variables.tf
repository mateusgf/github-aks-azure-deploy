variable "subscription_id" {
  description = "Azure subscription ID to deploy into."
  type        = string
  default     = "c0ae4ebe-9b84-4a13-8f45-c7cb699a3630"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "swedencentral"
}

variable "prefix" {
  description = "Short prefix used to name Azure resources."
  type        = string
  default     = "aks-deploy-example"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.prefix))
    error_message = "prefix must be 3-20 lowercase alphanumeric characters or hyphens."
  }
}

variable "environment" {
  description = "Environment name, used in resource naming/tags."
  type        = string
  default     = "dev"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster. Leave null to use the current AKS default."
  type        = string
  default     = null
}

variable "node_count" {
  description = "Number of nodes in the default AKS node pool."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for the default AKS node pool."
  type        = string
  default     = "Standard_B2s_v2"
}

variable "ci_principal_object_id" {
  description = "Object ID of the service principal used by GitHub Actions, granted AcrPush on the registry so it can push images."
  type        = string
  default     = "6c363f8a-8a7b-4cc3-bd22-d278d715de11"
}
