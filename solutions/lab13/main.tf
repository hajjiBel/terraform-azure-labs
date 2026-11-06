data "azurerm_client_config" "current" {}

# Groupe de ressources PRÉPARÉ par le formateur : votre SP y est User Access Administrator,
# ce qui lui permet de créer un rôle personnalisé et une attribution (impossible avec Contributor seul).
data "azurerm_resource_group" "lab13" {
  name = "rg-${var.owner_id}-lab13"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "demo" {
  name                            = "st${var.owner_id}${random_string.suffix.result}" # ≤ 24 caractères
  resource_group_name             = data.azurerm_resource_group.lab13.name
  location                        = data.azurerm_resource_group.lab13.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "demo" {
  name                  = "demo"
  storage_account_id    = azurerm_storage_account.demo.id
  container_access_type = "private"
}

locals {
  policy = templatefile("${path.module}/templates/storage_role.json.tpl", {
    owner_id             = var.owner_id
    role_name            = "role-${var.owner_id}-storage"
    storage_account_name = azurerm_storage_account.demo.name
    scope                = data.azurerm_resource_group.lab13.id
  })

  role = jsondecode(local.policy)
}

resource "azurerm_role_definition" "storage" {
  name        = local.role.Name
  description = local.role.Description
  scope       = data.azurerm_resource_group.lab13.id

  permissions {
    actions      = local.role.Actions
    data_actions = local.role.DataActions
  }

  assignable_scopes = local.role.AssignableScopes
}

resource "azurerm_role_assignment" "me" {
  scope              = azurerm_storage_account.demo.id
  role_definition_id = azurerm_role_definition.storage.role_definition_resource_id
  principal_id       = data.azurerm_client_config.current.object_id
}
