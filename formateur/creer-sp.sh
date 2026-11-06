#!/usr/bin/env bash
# Crée, pour chaque stagiaire listé dans stagiaires.txt :
#   - un Service Principal sp-terraform-<identity> (Contributor sur l'abonnement)
#   - le groupe de ressources rg-<identity>-lab13 + rôle User Access Administrator dessus
#   - un fichier formateur/out/<identity>.azure-tf.env (droits 600) à distribuer
#
# Usage : bash formateur/creer-sp.sh [fichier_stagiaires] [region]
# Prérequis : az login avec un compte Owner de l'abonnement.
set -euo pipefail

FICHIER="${1:-formateur/stagiaires.txt}"
LOCATION="${2:-francecentral}"
OUT="formateur/out"

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "🟦 Abonnement : $(az account show --query name -o tsv) ($SUBSCRIPTION_ID)"
read -r -p "Continuer ? [o/N] " ok
[[ "$ok" == "o" ]] || exit 1

mkdir -p "$OUT"
chmod 700 "$OUT"

while read -r IDENTITY; do
  [[ -z "$IDENTITY" || "$IDENTITY" == \#* ]] && continue
  if [[ ! "$IDENTITY" =~ ^[a-z0-9]{3,12}$ ]]; then
    echo "🟥 Identifiant invalide ignoré : '$IDENTITY' (attendu : [a-z0-9]{3,12})"
    continue
  fi

  echo "🟩 $IDENTITY"
  SP_JSON=$(az ad sp create-for-rbac \
    --name "sp-terraform-${IDENTITY}" \
    --role "Contributor" \
    --scopes "/subscriptions/${SUBSCRIPTION_ID}" \
    --output json)

  APP_ID=$(echo "$SP_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["appId"])')
  SECRET=$(echo "$SP_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["password"])')

  # Lab 13 : groupe de ressources préparé + droit de gérer les rôles uniquement dessus
  RG13="rg-${IDENTITY}-lab13"
  az group create --name "$RG13" --location "$LOCATION" --tags Owner="$IDENTITY" Formation=terraform -o none
  # La propagation Entra ID du nouveau SP peut prendre quelques secondes
  for i in 1 2 3 4 5; do
    if az role assignment create --assignee "$APP_ID" --role "User Access Administrator" \
         --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG13}" -o none 2>/dev/null; then
      break
    fi
    sleep 10
  done

  ENV_FILE="${OUT}/${IDENTITY}.azure-tf.env"
  cat > "$ENV_FILE" <<EOF
# Service Principal de ${IDENTITY} — formation Terraform Azure
# À copier vers ~/.azure-tf.env puis : chmod 600 ~/.azure-tf.env && source ~/.azure-tf.env
# NE JAMAIS VERSIONNER CE FICHIER.
export ARM_CLIENT_ID="${APP_ID}"
export ARM_CLIENT_SECRET="${SECRET}"
export ARM_TENANT_ID="${TENANT_ID}"
export ARM_SUBSCRIPTION_ID="${SUBSCRIPTION_ID}"
EOF
  chmod 600 "$ENV_FILE"
done < "$FICHIER"

echo
echo "✅ Fichiers générés dans ${OUT}/ — à distribuer individuellement, puis à supprimer."
