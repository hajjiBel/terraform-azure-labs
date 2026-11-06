# Un module déclare les providers dont il a besoin (sans bloc provider : il hérite de la racine).
terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
