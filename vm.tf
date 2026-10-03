resource "azurerm_bastion_host" "bastion_host" {
  name                = "bastion_host"
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  sku                 = "Standard"

  tunneling_enabled = true

  ip_configuration {
    name                 = "bastion_ip_config"
    subnet_id            = azurerm_subnet.bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.bastion-public-ip.id
  }
  tags = local.tags
}


resource "azurerm_network_interface" "nic-spoke1" {
  name                = "nic-spoke1"
  location            = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name = azurerm_resource_group.Secure-Landing-Zone-IaC.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.VM-PRIVATE-IP
  }

  tags = local.tags
}

resource "azurerm_virtual_machine" "vm-spoke1" {
  name                          = "vm-spoke1"
  location                      = azurerm_resource_group.Secure-Landing-Zone-IaC.location
  resource_group_name           = azurerm_resource_group.Secure-Landing-Zone-IaC.name
  network_interface_ids         = [azurerm_network_interface.nic-spoke1.id]
  vm_size                       = "Standard_B2ts_v2"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "osdisk-spoke1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {

    computer_name  = "vm-spoke1"
    admin_username = var.username


  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = var.public_key
      path     = "/home/${var.username}/.ssh/authorized_keys"
    }
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "vm_blob_data_reader" {
  scope                = azurerm_storage_account.slzstorageiac.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_virtual_machine.vm-spoke1.identity[0].principal_id
}