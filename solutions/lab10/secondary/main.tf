# Projet "secondary" : il lit les OUTPUTS d'autres états Terraform.
data "terraform_remote_state" "primary" {
  backend = "local"

  config = {
    path = "../primary/terraform.tfstate"
  }
}

output "primary_public_ip" {
  value = data.terraform_remote_state.primary.outputs.public_ip
}

# Tâche 3 : l'état du fil rouge (~/terraform-azure/terraform)
data "terraform_remote_state" "fil_rouge" {
  backend = "local"

  config = {
    path = "../../terraform/terraform.tfstate"
  }
}

output "serveurs_web" {
  value = {
    ips  = data.terraform_remote_state.fil_rouge.outputs.public_ip
    urls = data.terraform_remote_state.fil_rouge.outputs.urls
  }
}

# Défi : valeur par défaut si l'output n'existe pas
output "image_version_ou_defaut" {
  value = try(data.terraform_remote_state.fil_rouge.outputs.image_version, "inconnue")
}
