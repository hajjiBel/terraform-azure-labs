#!/usr/bin/env bash
# Fin de formation : supprime pour chaque stagiaire ses groupes de ressources rg-<identity>-*,
# ses rôles personnalisés role-<identity>-* et son Service Principal.
# Usage : bash formateur/nettoyage-formateur.sh [fichier_stagiaires]
set -euo pipefail

FICHIER="${1:-formateur/stagiaires.txt}"
echo "🟥 ATTENTION : suppression définitive des ressources de tous les stagiaires de $FICHIER"
read -r -p "Tapez SUPPRIMER pour confirmer : " ok
[[ "$ok" == "SUPPRIMER" ]] || exit 1

while read -r IDENTITY; do
  [[ -z "$IDENTITY" || "$IDENTITY" == \#* ]] && continue
  echo "🧹 $IDENTITY"

  for RG in $(az group list --query "[?starts_with(name,'rg-${IDENTITY}-')].name" -o tsv); do
    echo "   - groupe $RG"
    az group delete --name "$RG" --yes --no-wait
  done

  for ROLE in $(az role definition list --custom-role-only true \
                 --query "[?starts_with(roleName,'role-${IDENTITY}-')].roleName" -o tsv); do
    echo "   - rôle $ROLE"
    az role definition delete --name "$ROLE" || true
  done

  APP_ID=$(az ad sp list --display-name "sp-terraform-${IDENTITY}" --query "[0].appId" -o tsv)
  if [[ -n "$APP_ID" ]]; then
    echo "   - SP $APP_ID"
    az ad app delete --id "$APP_ID"
  fi
done < "$FICHIER"

rm -rf formateur/out
echo "✅ Terminé (les suppressions de groupes continuent en arrière-plan : az group list -o table)."
