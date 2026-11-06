# 📕 Corrigé formateur — Lab 14

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code complet : [`solutions/lab14/`](../solutions/lab14/)

## ⏱️ Déroulé conseillé (45 min)

| Min | Activité |
|---|---|
| 0–10 | Providers, jeton en variable d'environnement |
| 10–25 | Réseau + VM + test sans restriction (~4 min de création) |
| 25–40 | Règles sortantes, `depends_on`, échec volontaire |
| 40–45 | Destroy, questions |

> [!TIP]
> Toute la salle sort souvent par **la même IP publique** : en mode anonyme, la limite de 60 appels/h de l'API GitHub peut être atteinte. Faites créer le jeton (sans permission) dès le début.

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `"integrations/github"` |
| 2 | `data.github_ip_ranges.gh.pages_ipv4` |
| 3 | voir ci-dessous. Aucun attribut de la VM ne référence les règles NSG : sans référence, pas d'arête dans le graphe, et Terraform pourrait créer la VM (et lancer le test) **avant** les règles. |
| 4 | 28 = *Operation timeout* : la connexion vers hashicorp.com est bloquée (paquets ignorés par le Deny). La VM est **tainted** : elle sera recréée au prochain `apply`. |

```hcl
  depends_on = [
    azurerm_network_security_rule.ssh_in,
    azurerm_subnet_network_security_group_association.vm,
    azurerm_network_security_rule.allow_github_pages,
    azurerm_network_security_rule.deny_internet,
  ]
```

**Défi** :

```hcl
destination_address_prefixes = concat(data.github_ip_ranges.gh.pages_ipv4, data.github_ip_ranges.gh.git_ipv4)
```

> [!WARNING]
> `git_ipv4` contient de nombreuses plages : vérifiez la limite de préfixes par règle NSG si le plan échoue.

## ❓ Réponses aux questions

1. `azurerm` : variables `ARM_*` ; `github` : `GITHUB_TOKEN` (ou anonyme). Aucun secret dans les fichiers.
2. La dépendance est **comportementale** (le provisioner teste le réseau), pas une dépendance de données : Terraform ne peut pas la déduire.
3. Les règles sont évaluées par priorité croissante et la première qui correspond s'applique : l'Allow (100) doit passer **avant** le Deny (4000). Laisser de la marge entre les deux permet d'insérer d'autres Allow plus tard.
4. Ressource **optionnelle** : 0 ou 1 instance selon un booléen. C'est l'usage où `count` reste préférable à `for_each`.

## 🧯 Pièges observés en session

- 🟥 Jeton GitHub collé dans `terraform.tfvars` puis poussé sur GitHub : GitHub le révoque automatiquement (secret scanning). Bonne occasion d'en parler.
- 🟧 `terraform destroy` sans `-var="restrict_egress=true"` : fonctionne aussi (les règles sont détruites avec le NSG), mais le plan affiche d'abord leur suppression.
