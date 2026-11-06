resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.identity}-lab15"
  location = var.location
}

# Réseau principal
resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Name = "main"
  }
}

locals {
  subnets = {
    public-1  = { cidr = "10.0.1.0/24", public = true }
    public-2  = { cidr = "10.0.2.0/24", public = true }
    public-3  = { cidr = "10.0.3.0/24", public = true }
    private-1 = { cidr = "10.0.4.0/24", public = false }
    private-2 = { cidr = "10.0.5.0/24", public = false }
    private-3 = { cidr = "10.0.6.0/24", public = false }
  }

  public_subnets  = { for k, v in local.subnets : k => v if v.public }
  private_subnets = { for k, v in local.subnets : k => v if !v.public }
}

resource "azurerm_subnet" "main" {
  for_each = local.subnets

  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.cidr]

  # Sous-réseaux privés : pas d'accès sortant implicite, la sortie passe par la NAT Gateway
  default_outbound_access_enabled = each.value.public
}

# Table de routage des sous-réseaux publics (explicite : modifiable plus tard vers un pare-feu)
resource "azurerm_route_table" "public" {
  name                = "rt-public"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "default-to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    Name = "main-public"
  }
}

resource "azurerm_subnet_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = azurerm_subnet.main[each.key].id
  route_table_id = azurerm_route_table.public.id
}
