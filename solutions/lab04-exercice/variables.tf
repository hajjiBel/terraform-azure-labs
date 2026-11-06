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

variable "env" {
  type    = string
  default = "dev"
}

variable "allowed_ssh_cidr" {
  type = string
}

# 3. Taille de VM selon l'environnement
variable "vm_sizes" {
  type = map(string)
  default = {
    dev  = "Standard_B1s"
    test = "Standard_B1ms"
    prod = "Standard_B2s"
  }
}

# 4. Bonus : map d'objets pour l'image
variable "images" {
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
  }))
  default = {
    ubuntu2404 = { publisher = "Canonical", offer = "ubuntu-24_04-lts", sku = "server" }
    ubuntu2204 = { publisher = "Canonical", offer = "0001-com-ubuntu-server-jammy", sku = "22_04-lts-gen2" }
    debian12   = { publisher = "Debian", offer = "debian-12", sku = "12-gen2" }
  }
}

variable "os" {
  type    = string
  default = "ubuntu2404"

  validation {
    condition     = contains(["ubuntu2404", "ubuntu2204", "debian12"], var.os)
    error_message = "os doit être ubuntu2404, ubuntu2204 ou debian12."
  }
}
