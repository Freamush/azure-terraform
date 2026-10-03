resource "azurerm_resource_group" "Secure-Landing-Zone-IaC" {
  name     = "Secure-Landing-Zone-IaC"
  location = "Sweden Central"
  tags     = local.tags
}

