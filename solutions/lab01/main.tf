# Lab 01 — Test de connexion : aucune ressource créée, uniquement une lecture.
terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  # subscription_id n'est PAS écrit ici : le provider lit ARM_SUBSCRIPTION_ID.
}

# Identité avec laquelle Terraform s'authentifie (SP ou utilisateur az login)
data "azurerm_client_config" "current" {}

output "connexion" {
  value = {
    tenant_id       = data.azurerm_client_config.current.tenant_id
    subscription_id = data.azurerm_client_config.current.subscription_id
    client_id       = data.azurerm_client_config.current.client_id
    object_id       = data.azurerm_client_config.current.object_id
  }
}
