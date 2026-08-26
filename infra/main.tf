resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  name_suffix = random_string.suffix.result

  common_tags = {
    environment = var.environment
    project     = var.prefix
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}
