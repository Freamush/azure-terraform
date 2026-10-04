
output "Resource-Group-Output" {
  description = "The Azure Resource Group Name"
  value       = azurerm_resource_group.Secure-Landing-Zone-IaC.name
}

output "Virtual-Network-Output" {
  description = "The Azure Virtual Network Name"
  value = {
    hub    = azurerm_virtual_network.vnet-lz-hub.name
    spoke1 = azurerm_virtual_network.vnet-lz-spoke1.name
    spoke2 = azurerm_virtual_network.vnet-lz-spoke2.name
  }
}

output "Peering-Output" {
  description = "The Azure Subscription ID"
  value = {
    peer1 = azurerm_virtual_network_peering.hub-to-spoke1
    peer2 = azurerm_virtual_network_peering.spoke1-to-hub
    peer3 = azurerm_virtual_network_peering.hub-to-spoke2
    peer4 = azurerm_virtual_network_peering.spoke2-to-hub
  }
}

output "bastion_public_ip_address" {
  description = "The public IP address of the Azure Bastion host"
  value       = azurerm_public_ip.bastion-public-ip.ip_address
}

output "work_space_id" {
  description = "Workspace log analytics id"
  value       = azurerm_log_analytics_workspace.log_space.id
}

output "vm_spoke1_id" {
  description = "The Azure Virtual Machine ID"
  value       = azurerm_virtual_machine.vm-spoke1.id
}