output "public_ip" {
  description = "IP publique du serveur"
  value       = azurerm_public_ip.web.ip_address
}

output "public_dns" {
  description = "FQDN public du serveur"
  value       = azurerm_public_ip.web.fqdn
}

output "private_ip" {
  description = "IP privée du serveur"
  value       = azurerm_linux_virtual_machine.web.private_ip_address
}
