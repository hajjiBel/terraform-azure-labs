#!/usr/bin/env bash
# Filet de sécurité du stagiaire : supprime TOUS ses groupes de ressources rg-<identity>-*.
# À utiliser après les "terraform destroy", en fin de journée.
# Usage : bash scripts/nettoyage.sh <identity>
set -euo pipefail

IDENTITY="${1:-${TF_VAR_identity:-}}"
if [[ ! "$IDENTITY" =~ ^[a-z0-9]{3,12}$ ]]; then
  echo "Usage : bash scripts/nettoyage.sh <identity>   (ex. student01)"
  exit 1
fi

RGS=$(az group list --query "[?starts_with(name,'rg-${IDENTITY}-')].name" -o tsv)
if [[ -z "$RGS" ]]; then
  echo "✅ Aucun groupe de ressources rg-${IDENTITY}-* : rien à nettoyer."
  exit 0
fi

echo "🟥 Groupes qui vont être supprimés :"
echo "$RGS" | sed 's/^/   - /'
echo "⚠️  Le groupe rg-${IDENTITY}-lab13 est préparé par le formateur : il est conservé."
read -r -p "Confirmer ? [o/N] " ok
[[ "$ok" == "o" ]] || exit 1

for RG in $RGS; do
  [[ "$RG" == "rg-${IDENTITY}-lab13" ]] && continue
  az group delete --name "$RG" --yes --no-wait
  echo "🧹 suppression lancée : $RG"
done
echo "Suivi : az group list --query \"[?starts_with(name,'rg-${IDENTITY}-')].{nom:name, etat:properties.provisioningState}\" -o table"
