# 📕 Corrigé formateur — Lab 16

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code complet : [`solutions/lab16/`](../solutions/lab16/)

## ⏱️ Déroulé conseillé (40 min)

| Min | Activité |
|---|---|
| 0–15 | Clé, NSG, VM, apply |
| 15–30 | Tests sur la VM (IP, routes, IMDS, routes effectives) |
| 30–40 | Bonus VM privée (ou démonstration) + **destroy** |

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `azurerm_subnet.main["public-1"].id` |
| 2 | `vm_public_ip = azurerm_public_ip.web.ip_address` ; `vm_private_ip = azurerm_linux_virtual_machine.web.private_ip_address` |
| 3 | `Plan: 5 to add, 0 to change, 0 to destroy.` (NSG, IP publique, NIC, association NIC ↔ NSG, VM). Aucune ressource du lab 15 n'est modifiée. |
| 4 | voir [`solutions/lab16/instance-private.tf`](../solutions/lab16/instance-private.tf) — `Plan: 2 to add`. |

## ❓ Réponses aux questions

1. Le sous-réseau est une construction **régionale** qui couvre toutes les zones ; la zone est une propriété du matériel qui héberge la ressource (VM, disque, IP zonale).
2. Sur le subnet : s'applique à toutes les NIC du subnet. Sur la NIC : à cette seule VM. Si les deux existent, le trafic doit être autorisé par **les deux**.
3. Toutes les VM d'un VNet communiquent par défaut (route système du VNet, règle NSG par défaut `AllowVnetInBound`). Depuis Internet, il n'y a ni IP publique ni règle entrante, et la NAT Gateway ne laisse passer que les flux **sortants** et leurs réponses.
4. IMDS : nom, taille, zone, région, tags de la VM, et jetons d'identité managée, accessibles uniquement depuis la VM.

## 🧯 Pièges observés en session

- 🟧 Ancienne version : `route -n` → *command not found* sur Ubuntu 24.04. Corrigé en `ip route`.
- 🟧 B1s indisponible en zone 1 certains jours : d'où `var.vm_zone`.
- 🟥 Oubli du `destroy` final : NAT Gateway + 2 VM facturées tout le week-end. Lancer [`formateur/nettoyage-formateur.sh`](../formateur/nettoyage-formateur.sh) le soir même.
