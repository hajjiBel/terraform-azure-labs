variable "identity" {
  type = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.identity))
    error_message = "identity : 3 à 12 caractères, minuscules et chiffres."
  }
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "allowed_ssh_cidr" {
  description = "Votre IP au format CIDR (curl -s ifconfig.me)"
  type        = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "vm_zone" {
  description = "Zone de disponibilité de la VM et de son IP (az vm list-skus …)"
  type        = string
  default     = "1"
}

variable "path_to_public_key" {
  type    = string
  default = "mykey.pub"
}

variable "instance_username" {
  type    = string
  default = "azureuser"
}
