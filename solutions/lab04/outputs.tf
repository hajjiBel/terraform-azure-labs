output "public_ip" {
  description = "Adresse IP publique du serveur web"
  value       = azurerm_public_ip.web.ip_address
}

output "public_dns" {
  description = "Nom DNS public du serveur web"
  value       = azurerm_public_ip.web.fqdn
}

# Exercice 1
output "private_ip" {
  description = "Adresse IP privée de la VM"
  value       = azurerm_linux_virtual_machine.web.private_ip_address
}

# Exercice 2 : interpolation de chaîne
output "ssh_command" {
  description = "Commande SSH prête à copier"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.web.ip_address}"
}
