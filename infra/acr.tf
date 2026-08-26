resource "azurerm_container_registry" "main" {
  # ACR names must be globally unique, alphanumeric only.
  name                = replace("acr${var.prefix}${local.name_suffix}", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.common_tags
}
