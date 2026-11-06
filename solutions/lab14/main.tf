# Plages d'IP publiées par GitHub (hooks, git, pages, actions...)
data "github_ip_ranges" "gh" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.identity}-lab14"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-lab14"
  address_space       = ["10.14.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.14.1.0/24"]
}

resource "azurerm_network_security_group" "egress" {
  name                = "nsg-egress"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "ssh_in" {
  name                        = "Allow-SSH-In"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.allowed_ssh_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.egress.name
}

# --- Tâche 2 : règles sortantes, créées seulement si restrict_egress = true ---
resource "azurerm_network_security_rule" "allow_github_pages" {
  count = var.restrict_egress ? 1 : 0

  name                         = "Allow-GitHub-Pages-Out"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = data.github_ip_ranges.gh.pages_ipv4
  resource_group_name          = azurerm_resource_group.rg.name
  network_security_group_name  = azurerm_network_security_group.egress.name
}

resource "azurerm_network_security_rule" "deny_internet" {
  count = var.restrict_egress ? 1 : 0

  name                        = "Deny-Internet-Out"
  priority                    = 4000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet" # service tag Azure
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.egress.name
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.egress.id
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_public_ip" "vm" {
  name                = "pip-egress"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-egress"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-egress"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
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

  # Les règles NSG doivent exister AVANT le test réseau du provisioner.
  # Aucune référence ne les relie à la VM : dépendance explicite.
  depends_on = [
    azurerm_network_security_rule.ssh_in,
    azurerm_subnet_network_security_group_association.vm,
    azurerm_network_security_rule.allow_github_pages,
    azurerm_network_security_rule.deny_internet,
  ]

  connection {
    type        = "ssh"
    user        = "azureuser"
    private_key = tls_private_key.ssh.private_key_pem
    host        = self.public_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "echo '--- GitHub Pages ---'",
      "curl -s -o /dev/null -w 'HTTP %%{http_code}\\n' --max-time 10 https://pages.github.com",
      "echo '--- hashicorp.com ---'",
      "curl -s -o /dev/null -w 'HTTP %%{http_code}\\n' --max-time 10 https://www.hashicorp.com",
    ]
  }
}

output "github_pages_ipv4" {
  value = data.github_ip_ranges.gh.pages_ipv4
}
