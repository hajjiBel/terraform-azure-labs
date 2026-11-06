# Avec for_each, chaque output est une MAP : clé du serveur => valeur
output "public_ip" {
  description = "IP publiques, par serveur"
  value       = { for k, p in azurerm_public_ip.web : k => p.ip_address }
}

output "public_dns" {
  description = "FQDN publics, par serveur"
  value       = { for k, p in azurerm_public_ip.web : k => p.fqdn }
}

output "private_ip" {
  description = "IP privées, par serveur"
  value       = { for k, vm in azurerm_linux_virtual_machine.web : k => vm.private_ip_address }
}

output "image_version" {
  description = "Dernière version d'image lue par la source de données"
  value       = data.azurerm_platform_image.ubuntu.version
}
