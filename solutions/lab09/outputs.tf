output "public_ip" {
  description = "IP publiques des serveurs web (map)"
  value       = module.server.public_ip
}

output "public_dns" {
  description = "FQDN des serveurs web (map)"
  value       = module.server.public_dns
}

output "private_ip" {
  description = "IP privées des serveurs (map)"
  value       = module.server.private_ip
}

output "ssh_commands" {
  description = "Commandes SSH, par serveur"
  value       = { for k, ip in module.server.public_ip : k => "ssh -i keys/${var.identity}.pem ${var.admin_username}@${ip}" }
}

output "urls" {
  description = "URL des serveurs web"
  value       = [for d in values(module.server.public_dns) : "http://${d}"]
}

output "noms_recommandes" {
  description = "Noms conformes calculés par le module Azure/naming"
  value = {
    resource_group  = module.naming.resource_group.name
    virtual_network = module.naming.virtual_network.name
    storage_account = module.naming.storage_account.name_unique
  }
}

output "image_version" {
  description = "Version de l'image Ubuntu la plus récente dans la région"
  value       = module.server.image_version
}

output "identite" {
  description = "Identité qui exécute Terraform"
  value = {
    tenant_id       = data.azurerm_client_config.current.tenant_id
    subscription_id = data.azurerm_client_config.current.subscription_id
    object_id       = data.azurerm_client_config.current.object_id
  }
}

output "shared_rg" {
  description = "Groupe de ressources lu par une source de données"
  value = {
    id       = data.azurerm_resource_group.shared.id
    location = data.azurerm_resource_group.shared.location
    tags     = data.azurerm_resource_group.shared.tags
  }
}
