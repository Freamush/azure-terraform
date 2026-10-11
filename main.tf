resource "azurerm_resource_group" "Secure-Landing-Zone-IaC" {
  name     = "Secure-Landing-Zone-IaC"
  location = "Sweden Central"
  tags     = local.tags
}

module "spoke1" {
  source              = "./modules/spoke"
  name                = "vnet-lz-spoke1"
  rg_name             = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  hub_id              = azurerm_virtual_network.vnet-lz-hub.id
  hub_name            = azurerm_virtual_network.vnet-lz-hub.name
  vnet_cidr           = var.SPOKE1-IP-CIDR
  subnet_cidr         = local.subnet2_cidr
  firewall_private_ip = azurerm_firewall.az-firewall.ip_configuration[0].private_ip_address
  tags                = local.tags
  private_zone_id     = azurerm_private_dns_zone.private-zone.id
}

module "spoke2" {
  source                  = "./modules/spoke"
  name                    = "vnet-lz-spoke2"
  rg_name                 = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  location                = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  hub_id                  = azurerm_virtual_network.vnet-lz-hub.id
  hub_name                = azurerm_virtual_network.vnet-lz-hub.name
  vnet_cidr               = var.SPOKE2-IP-CIDR
  subnet_cidr             = local.subnet3_cidr
  firewall_private_ip     = azurerm_firewall.az-firewall.ip_configuration[0].private_ip_address
  tags                    = local.tags
  private_endpoint_policy = "Enabled"
  route_prefix            = "10.0.0.0/16"
  private_zone_id         = azurerm_private_dns_zone.private-zone.id
}

resource "azurerm_private_dns_zone" "private-zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name

  tags = local.tags
}

resource "azurerm_public_ip" "bastion-public-ip" {
  name                = "bastion-public-ip"
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}