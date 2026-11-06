# Bonus : VM sans IP publique, sortie vers Internet par la NAT Gateway
resource "azurerm_network_interface" "private" {
  name                = "nic-private"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main["private-1"].id
    private_ip_address_allocation = "Dynamic"
    # aucune IP publique
  }
}

resource "azurerm_linux_virtual_machine" "private" {
  name                  = "vm-private"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm_size
  admin_username        = var.instance_username
  network_interface_ids = [azurerm_network_interface.private.id]

  admin_ssh_key {
    username   = var.instance_username
    public_key = file(var.path_to_public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
