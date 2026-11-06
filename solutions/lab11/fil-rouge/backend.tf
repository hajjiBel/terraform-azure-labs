# À ajouter dans ~/terraform-azure/terraform (fil rouge), puis :
#   terraform init -migrate-state \
#     -backend-config="resource_group_name=$TFSTATE_RG" \
#     -backend-config="storage_account_name=$TFSTATE_SA"
terraform {
  backend "azurerm" {
    container_name = "tfstate"
    key            = "fil-rouge.tfstate"
  }
}
