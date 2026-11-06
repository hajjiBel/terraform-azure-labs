# Lab 05 — Le serveur (IP publique, NIC, VM) est désormais dans le module ./modules/server.

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.identity}-lab"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.identity}"
  address_space       = var.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# --- Tâche 3 : paire de clés SSH générée par Terraform ---------------------
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ⚠️ La clé privée est aussi stockée EN CLAIR dans l'état : acceptable en formation uniquement.
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.root}/keys/${var.identity}.pem"
  file_permission = "0600"
}

# --- Tâche 1 : appel du module local ----------------------------------------
module "server" {
  source = "./modules/server"

  identity            = var.identity
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.web.id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  public_key          = tls_private_key.ssh.public_key_openssh
  private_key         = tls_private_key.ssh.private_key_pem
  tags                = var.tags
}

# Déplacement des ressources dans le module SANS les recréer
moved {
  from = azurerm_public_ip.web
  to   = module.server.azurerm_public_ip.web
}

moved {
  from = azurerm_network_interface.web
  to   = module.server.azurerm_network_interface.web
}

moved {
  from = azurerm_linux_virtual_machine.web
  to   = module.server.azurerm_linux_virtual_machine.web
}

# --- Tâche 2 : module public du registre (calcule des noms, aucune ressource Azure) -----
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"

  suffix = [var.identity]
}
