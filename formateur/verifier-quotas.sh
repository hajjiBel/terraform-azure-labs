#!/usr/bin/env bash
# Vérifie que la région a assez de quota pour N stagiaires.
# Usage : bash formateur/verifier-quotas.sh [region] [nb_stagiaires]
set -euo pipefail

LOCATION="${1:-francecentral}"
N="${2:-15}"
BESOIN_VCPU=$(( N * 3 ))   # pic : 3 VM B1s par stagiaire (lab 08)
BESOIN_IP=$(( N * 4 ))

echo "🟦 Région : $LOCATION · stagiaires : $N"
echo "   Besoin estimé : ${BESOIN_VCPU} vCPU famille B, ${BESOIN_IP} IP publiques Standard"
echo

az vm list-usage --location "$LOCATION" \
  --query "[?contains(name.value,'standardBSFamily') || name.value=='cores'].{Quota:localName, Utilise:currentValue, Limite:limit}" \
  -o table

echo
az network list-usages --location "$LOCATION" \
  --query "[?name.value=='StandardSkuPublicIpAddresses' || name.value=='PublicIPAddresses'].{Quota:localName, Utilise:currentValue, Limite:limit}" \
  -o table

echo
echo "🔍 Disponibilité de Standard_B1s par zone :"
az vm list-skus --location "$LOCATION" --size Standard_B1s \
  --query "[].{Taille:name, Zones:join(',', locationInfo[0].zones), Restrictions:length(restrictions)}" -o table
