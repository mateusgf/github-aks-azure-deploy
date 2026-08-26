resource "azurerm_container_registry" "main" {
  # ACR names must be globally unique, alphanumeric only.
  name                = replace("acr${var.prefix}${local.name_suffix}", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.common_tags
}

# Contributor (granted to the GitHub Actions SP) only covers control-plane
# actions; pushing images needs this data-plane role explicitly.
resource "azurerm_role_assignment" "ci_acr_push" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = var.ci_principal_object_id
}
