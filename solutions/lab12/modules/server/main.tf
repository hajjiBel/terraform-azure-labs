# Lab 09 — Dernière image Ubuntu 24.04 publiée dans la région (lecture seule)
data "azurerm_platform_image" "ubuntu" {
  location  = var.location
  publisher = "Canonical"
  offer     = "ubuntu-24_04-lts"
  sku       = "server"
}

# Lab 08 — Une IP publique, une NIC et une VM PAR serveur, identifiés par une clé stable.
resource "azurerm_public_ip" "web" {
  for_each = toset(var.server_names)

  name                = "pip-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.identity}-${each.key}"
}

resource "azurerm_network_interface" "web" {
  for_each = toset(var.server_names)

  name                = "nic-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  for_each = toset(var.server_names)

  name                  = "vm-${each.key}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.web[each.key].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = data.azurerm_platform_image.ubuntu.publisher
    offer     = data.azurerm_platform_image.ubuntu.offer
    sku       = data.azurerm_platform_image.ubuntu.sku
    version   = data.azurerm_platform_image.ubuntu.version
  }

  # Lab 09 — Une nouvelle image publiée ne doit PAS recréer les VM existantes :
  # seules les nouvelles VM utiliseront la dernière version.
  lifecycle {
    ignore_changes = [source_image_reference]
  }

  tags = merge(var.tags, {
    Identity = var.identity
    Name     = each.key # ne dépend PAS du nombre de serveurs
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
