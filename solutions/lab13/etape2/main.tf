# Étapes 1-2 : rendu du modèle SANS Azure (copier templates/ à côté)
variable "owner_id" {
  type    = string
  default = "anaconda"
}

locals {
  storage_account_name = "st${var.owner_id}demo"

  policy = templatefile("${path.module}/templates/storage_role.json.tpl", {
    owner_id             = var.owner_id
    role_name            = "role-${var.owner_id}-storage"
    storage_account_name = local.storage_account_name
    scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-${var.owner_id}-lab13"
  })
}

output "role_policy" {
  value = local.policy
}
