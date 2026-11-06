# 📕 Corrigé formateur — Lab 15

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code complet : [`solutions/lab15/`](../solutions/lab15/)

## ⏱️ Déroulé conseillé (50 min)

| Min | Activité |
|---|---|
| 0–10 | Comparaison AWS / Azure (tableau) |
| 10–30 | VNet, sous-réseaux `for_each`, route table |
| 30–45 | NAT Gateway, calcul du plan, apply |
| 45–50 | Vérifications, questions |

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `{ for k, v in local.subnets : k => v if !v.public }` |
| 2 | voir ci-dessous |
| 3 | `local.private_subnets` |
| 4 | **18** : 1 groupe + 1 VNet + 6 sous-réseaux + 1 route table + 3 associations route table + 1 IP NAT + 1 NAT Gateway + 1 association NAT ↔ IP + 3 associations NAT ↔ subnet. `Plan: 18 to add, 0 to change, 0 to destroy.` |

```hcl
resource "azurerm_subnet_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = azurerm_subnet.main[each.key].id
  route_table_id = azurerm_route_table.public.id
}
```

**Défi** :

```hcl
locals {
  subnets = merge(
    { for n in range(1, 4) : "public-${n}" => { cidr = cidrsubnet("10.0.0.0/16", 8, n), public = true } },
    { for n in range(1, 4) : "private-${n}" => { cidr = cidrsubnet("10.0.0.0/16", 8, n + 3), public = false } },
  )
}
```

## ❓ Réponses aux questions

1. Le routage vers Internet est assuré par les **routes système** de la plateforme ; la connectivité publique est portée par l'IP publique (ou la NAT Gateway / le load balancer).
2. `default_outbound_access_enabled = false` (pas de sortie implicite), aucune IP publique sur ses VM, et une sortie **uniquement** via la NAT Gateway.
3. 32 − 5 = **27**.
4. Une seule définition à maintenir, des ressources adressées par clé stable, et l'ajout d'un sous-réseau = une ligne dans la map.

## 🧯 Pièges observés en session

- 🟧 NAT Gateway oubliée en fin de journée : coût permanent. Le script [`scripts/nettoyage.sh`](../scripts/nettoyage.sh) sert de filet.
- 🟨 Tentative de `zones` sur la NAT Gateway incompatible avec l'IP publique (zone différente) : laisser régional pour ce lab.
