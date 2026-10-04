resource "azurerm_virtual_network" "vnet-lz-hub" {
  name                = "vnet-lz-hub"
  address_space       = [var.HUB-IP-CIDR]
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  tags                = local.tags
}

resource "azurerm_virtual_network" "vnet-lz-spoke1" {
  name                = "vnet-lz-spoke1"
  address_space       = [var.SPOKE1-IP-CIDR]
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  tags                = local.tags

}

resource "azurerm_virtual_network" "vnet-lz-spoke2" {
  name                = "vnet-lz-spoke2"
  address_space       = [var.SPOKE2-IP-CIDR]
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  tags                = local.tags

}

resource "azurerm_subnet" "subnet1" {
  name                 = "snet-hub-shared"
  resource_group_name  = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  virtual_network_name = azurerm_virtual_network.vnet-lz-hub.name
  address_prefixes     = [local.subnet1_cidr]
}

resource "azurerm_subnet" "bastion-subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  virtual_network_name = azurerm_virtual_network.vnet-lz-hub.name
  address_prefixes     = [local.bastion_subnet_cidr]
  #checkov:skip=CKV2_AZURE_31
}

resource "azurerm_subnet" "subnet2" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  virtual_network_name = azurerm_virtual_network.vnet-lz-spoke1.name
  address_prefixes     = [local.subnet2_cidr]
}

resource "azurerm_subnet" "subnet3" {
  name                 = "snet-data-pe"
  resource_group_name  = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  virtual_network_name = azurerm_virtual_network.vnet-lz-spoke2.name
  address_prefixes     = [local.subnet3_cidr]

  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_virtual_network_peering" "hub-to-spoke1" {
  name                         = "hub-to-spoke1"
  resource_group_name          = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  virtual_network_name         = azurerm_virtual_network.vnet-lz-hub.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-lz-spoke1.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke1-to-hub" {
  name                         = "spoke1-to-hub"
  resource_group_name          = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  virtual_network_name         = azurerm_virtual_network.vnet-lz-spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-lz-hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub-to-spoke2" {
  name                         = "hub-to-spoke2"
  resource_group_name          = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  virtual_network_name         = azurerm_virtual_network.vnet-lz-hub.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-lz-spoke2.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke2-to-hub" {
  name                         = "spoke2-to-hub"
  resource_group_name          = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  virtual_network_name         = azurerm_virtual_network.vnet-lz-spoke2.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-lz-hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_network_security_group" "nsg-hub" {
  name                = "nsg-hub"
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "nsg-spoke1" {
  name                = "nsg-spoke1"
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "nsg-spoke2" {
  name                = "nsg-spoke2"
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  tags                = local.tags

}

resource "azurerm_subnet_network_security_group_association" "subnet1-nsg-association" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg-hub.id
}

resource "azurerm_subnet_network_security_group_association" "subnet2-nsg-association" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.nsg-spoke1.id
}

resource "azurerm_subnet_network_security_group_association" "subnet3-nsg-association" {
  subnet_id                 = azurerm_subnet.subnet3.id
  network_security_group_id = azurerm_network_security_group.nsg-spoke2.id
}

resource "azurerm_network_security_rule" "allow-ssh-from-bastion-to-spoke1" {
  name                        = "allow-ssh-from-bastion"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = azurerm_subnet.bastion-subnet.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.subnet2.address_prefixes[0]
  resource_group_name         = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  network_security_group_name = azurerm_network_security_group.nsg-spoke1.name
}

resource "azurerm_network_security_rule" "deny-all-other-traffic-spoke1" {
  name                        = "deny-all-other-traffic-spoke1"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  network_security_group_name = azurerm_network_security_group.nsg-spoke1.name
}

resource "azurerm_network_security_rule" "allow-443-to-spoke2" {
  name                        = "allow-443-from-spoke1-to-spoke2"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = azurerm_subnet.subnet2.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.subnet3.address_prefixes[0]
  resource_group_name         = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  network_security_group_name = azurerm_network_security_group.nsg-spoke2.name
}

resource "azurerm_network_security_rule" "deny-all-other-traffic-spoke2" {
  name                        = "deny-all-other-traffic-spoke2"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  network_security_group_name = azurerm_network_security_group.nsg-spoke2.name
}

resource "azurerm_public_ip" "bastion-public-ip" {
  name                = "bastion-public-ip"
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

resource "azurerm_private_dns_zone" "private-zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "private-zone-link-vnet-spoke1" {
  name                 = "private-zone-link-vnet-spoke1"
  private_dns_zone_id  = azurerm_private_dns_zone.private-zone.id
  virtual_network_id   = azurerm_virtual_network.vnet-lz-spoke1.id
  registration_enabled = false

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "private-zone-link-vnet-spoke2" {
  name                 = "private-zone-link-vnet-spoke2"
  private_dns_zone_id  = azurerm_private_dns_zone.private-zone.id
  virtual_network_id   = azurerm_virtual_network.vnet-lz-spoke2.id
  registration_enabled = false

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "private-zone-link-vnet-hub" {
  name                 = "private-zone-link-vnet-hub"
  private_dns_zone_id  = azurerm_private_dns_zone.private-zone.id
  virtual_network_id   = azurerm_virtual_network.vnet-lz-hub.id
  registration_enabled = false

  tags = local.tags
}

resource "azurerm_route_table" "route-table-spoke1" {
  name                = "route-table-spoke1"
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  route {
    name                   = "route-to-anywhere"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.az-firewall.ip_configuration[0].private_ip_address
  }
  tags = local.tags
}

resource "azurerm_route_table" "route-table-spoke2" {
  name                = "route-table-spoke2"
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  route {
    name                   = "route-to-spoke1"
    address_prefix         = "10.0.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.az-firewall.ip_configuration[0].private_ip_address
  }
  tags = local.tags
}

resource "azurerm_subnet_route_table_association" "subnet2-route-table-association" {
  subnet_id      = azurerm_subnet.subnet2.id
  route_table_id = azurerm_route_table.route-table-spoke1.id
}

resource "azurerm_subnet_route_table_association" "subnet3-route-table-association" {
  subnet_id      = azurerm_subnet.subnet3.id
  route_table_id = azurerm_route_table.route-table-spoke2.id
}