terraform {
  required_version = ">= 1.9"

  backend "azurerm" {
    container_name = "tfstate"
    key            = "lab11/read_state.tfstate"
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "random_id" "random" {
  keepers = {
    uuid = uuid()
  }
  byte_length = 8
}

# Lecture de l'état de write_state. Ici, les variables sont autorisées
# (contrairement au bloc backend, évalué avant les variables).
data "terraform_remote_state" "write_state" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_rg
    storage_account_name = var.tfstate_sa
    container_name       = "tfstate"
    key                  = "lab11/write_state.tfstate"
  }
}

output "random" {
  value = random_id.random.hex
}

output "write_state_random" {
  value = data.terraform_remote_state.write_state.outputs.random
}
