#!/usr/bin/env bash
# Lab 11 — Crée le stockage des états Terraform (problème de l'œuf et de la poule :
# il doit exister AVANT le premier "terraform init" qui l'utilise).
# Usage : bash bootstrap.sh <identity>
set -euo pipefail

IDENTITY="${1:?Usage : bash bootstrap.sh <identity>}"
[[ "$IDENTITY" =~ ^[a-z0-9]{3,12}$ ]] || { echo "identity invalide"; exit 1; }

RG="rg-${IDENTITY}-tfstate"
SA="sttf${IDENTITY}$(openssl rand -hex 3)"   # 3 à 24 caractères [a-z0-9], unique dans tout Azure
LOCATION="francecentral"

az group create --name "$RG" --location "$LOCATION" -o none

az storage account create \
  --name "$SA" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  -o none

# Versioning : permet de restaurer une version précédente de l'état
az storage account blob-service-properties update \
  --account-name "$SA" --resource-group "$RG" --enable-versioning true -o none

ACCOUNT_KEY=$(az storage account keys list -g "$RG" -n "$SA" --query '[0].value' -o tsv)
az storage container create --name tfstate --account-name "$SA" --account-key "$ACCOUNT_KEY" -o none

# On mémorise le nom du compte : il est aléatoire et sera demandé dans chaque backend
cat > ~/.tfstate.env <<EOT
export TFSTATE_RG="$RG"
export TFSTATE_SA="$SA"
export ARM_ACCESS_KEY="$ACCOUNT_KEY"
EOT
chmod 600 ~/.tfstate.env
echo "✅ Compte de stockage : $SA — variables enregistrées dans ~/.tfstate.env (source ~/.tfstate.env)"
