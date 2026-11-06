output "public_ip" {
  description = "Adresse IP publique du serveur web"
  value       = module.server.public_ip
}

output "public_dns" {
  description = "Nom DNS public du serveur web"
  value       = module.server.public_dns
}

output "private_ip" {
  description = "Adresse IP privée de la VM"
  value       = module.server.private_ip
}

output "ssh_command" {
  description = "Commande SSH avec la clé générée par Terraform"
  value       = "ssh -i keys/${var.identity}.pem ${var.admin_username}@${module.server.public_ip}"
}

output "noms_recommandes" {
  description = "Noms conformes calculés par le module Azure/naming"
  value = {
    resource_group  = module.naming.resource_group.name
    virtual_network = module.naming.virtual_network.name
    storage_account = module.naming.storage_account.name_unique
  }
}
