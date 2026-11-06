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
  # Authentification et abonnement lus depuis ARM_CLIENT_ID, ARM_CLIENT_SECRET,
  # ARM_TENANT_ID et ARM_SUBSCRIPTION_ID (fichier ~/.azure-tf.env du lab 01).
}
