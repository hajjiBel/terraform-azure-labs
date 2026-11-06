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
