variable "identity" {
  description = "Identifiant unique du participant (3 à 12 caractères, minuscules et chiffres)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.identity))
    error_message = "identity doit contenir 3 à 12 caractères, minuscules et chiffres uniquement (ex. student01)."
  }
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "francecentral"

  validation {
    condition     = contains(["francecentral", "westeurope", "northeurope"], var.location)
    error_message = "Région non autorisée pour la formation (francecentral, westeurope, northeurope)."
  }
}

variable "vm_size" {
  description = "Taille de la machine virtuelle"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Utilisateur administrateur de la VM"
  type        = string
  default     = "azureuser"
}

variable "address_space" {
  description = "Plage d'adresses du VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "allowed_ssh_cidr" {
  description = "Adresse autorisée en SSH, au format CIDR (votre IP : curl -s ifconfig.me)"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0)) || var.allowed_ssh_cidr == "*"
    error_message = "allowed_ssh_cidr doit être un CIDR valide, par exemple 203.0.113.10/32."
  }
}

variable "tags" {
  description = "Tags communs à toutes les ressources"
  type        = map(string)
  default = {
    Environment = "Training"
  }
}

variable "server_names" {
  description = "Serveurs web à déployer (clés stables)"
  type        = list(string)
  default     = ["web-1", "web-2"]
}
