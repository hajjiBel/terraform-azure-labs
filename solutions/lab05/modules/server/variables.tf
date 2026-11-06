variable "identity" {
  description = "Identifiant du participant, utilisé dans les noms"
  type        = string
}

variable "location" {
  description = "Région Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Groupe de ressources cible"
  type        = string
}

variable "subnet_id" {
  description = "ID du subnet où placer la carte réseau"
  type        = string
}

variable "vm_size" {
  description = "Taille de la VM"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Utilisateur administrateur"
  type        = string
  default     = "azureuser"
}

variable "public_key" {
  description = "Clé publique SSH au format OpenSSH"
  type        = string
}

variable "private_key" {
  description = "Clé privée SSH, utilisée par les provisioners au lab 06"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}
