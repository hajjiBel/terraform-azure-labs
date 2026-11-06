terraform {
  required_version = ">= 1.9"

  # Les valeurs propres au stagiaire sont passées à l'init (configuration partielle) :
  #   terraform init -backend-config="resource_group_name=$TFSTATE_RG" \
  #                  -backend-config="storage_account_name=$TFSTATE_SA"
  backend "azurerm" {
    container_name = "tfstate"
    key            = "lab11/write_state.tfstate"
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
    uuid = uuid() # nouvelle valeur à chaque apply (pour la démonstration)
  }
  byte_length = 8
}

output "random" {
  value = random_id.random.hex
}
