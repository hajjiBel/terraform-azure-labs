output "role_policy" {
  description = "JSON rendu par templatefile()"
  value       = local.policy
}

output "storage_account" {
  value = azurerm_storage_account.demo.name
}
