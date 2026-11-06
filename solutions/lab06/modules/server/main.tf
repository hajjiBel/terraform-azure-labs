resource "azurerm_public_ip" "web" {
  name                = "pip-web"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.identity}-web"
}

resource "azurerm_network_interface" "web" {
  name                = "nic-web"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web.id
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  name                  = "vm-web"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.web.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_key
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

  tags = merge(var.tags, {
    Identity = var.identity
    Name     = "Web"
  })

  # Lab 06 — Connexion SSH utilisée par les provisioners
  connection {
    type        = "ssh"
    user        = var.admin_username
    private_key = var.private_key
    host        = self.public_ip_address
  }

  # Copie le répertoire assets/ de la racine vers /tmp/assets
  provisioner "file" {
    source      = "${path.root}/assets"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait > /dev/null", # attendre la fin du démarrage (verrou apt)
      "sudo bash /tmp/assets/setup-web.sh",
    ]
  }
}
