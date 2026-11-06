# Lab 10 « secondary », adapté : le fil rouge lit désormais son état dans Azure.
variable "tfstate_rg" {
  type = string
}

variable "tfstate_sa" {
  type = string
}

data "terraform_remote_state" "fil_rouge" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_rg
    storage_account_name = var.tfstate_sa
    container_name       = "tfstate"
    key                  = "fil-rouge.tfstate"
  }
}

output "serveurs_web" {
  value = {
    ips  = data.terraform_remote_state.fil_rouge.outputs.public_ip
    urls = data.terraform_remote_state.fil_rouge.outputs.urls
  }
}
