variable "owner_id" {
  description = "Votre identifiant (entre dans le nom du compte de stockage)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.owner_id))
    error_message = "owner_id : 3 à 12 caractères, minuscules et chiffres."
  }
}
