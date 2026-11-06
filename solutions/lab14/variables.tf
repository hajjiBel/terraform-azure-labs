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

variable "restrict_egress" {
  description = "Tâche 2 : n'autoriser la sortie que vers GitHub Pages"
  type        = bool
  default     = false
}
