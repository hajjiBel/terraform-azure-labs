# 📕 Corrigé formateur — Lab 12

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code final : [`solutions/lab12/`](../solutions/lab12/)

## ⏱️ Déroulé conseillé (75 min)

| Min | Activité |
|---|---|
| 0–20 | Destroy local, adaptation du code, dépôt GitHub, workspace |
| 20–30 | Variables |
| 30–40 | Plan en échec + diagnostic |
| 40–55 | PR, plan spéculatif, merge |
| 55–70 | Apply (~6 min avec les provisioners) + test |
| 70–75 | Destroy |

> [!TIP]
> Créez **à l'avance** une organisation HCP Terraform de démonstration : si un stagiaire n'arrive pas à créer la sienne, il suit sur votre écran.

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `count = var.write_private_key ? 1 : 0` |
| 2 | Sans **HCL**, HCP transmet la **chaîne** `"false"` ; avec HCL, la valeur booléenne `false`. Terraform convertit en général `"false"` en booléen, mais cocher HCL est indispensable pour les listes, maps et objets : autant prendre l'habitude. |
| 3 | `Error: Resource Group "rg-<identity>-shared" was not found` sur `data "azurerm_resource_group" "shared"`. En local, le groupe existait encore ; il a été supprimé à l'étape 1.1. Une source de données qui ne trouve rien fait **échouer** le plan. |
| 4 | Supprimer le bloc `data "azurerm_resource_group" "shared"` (`main.tf`) et l'output `shared_rg` (`outputs.tf`). |
| 5 | Environ 17 ressources : RG, VNet, subnet, NSG, association, clé TLS, 2 × (pip, nic, vm), ressources `random` du module `naming`, `terraform_data` éventuel du défi du lab 09. `local_sensitive_file` n'apparaît **pas** (`count = 0`). |

**Défi** : l'auto-apply applique tout plan réussi **sans relecture** : un merge malheureux (ou un `-/+` inattendu) part directement en production. À réserver aux environnements jetables.

## ❓ Réponses aux questions

1. Les deux états (local et HCP) décriraient les mêmes ressources : chacun croirait en être propriétaire (conflits de noms, destructions croisées).
2. Un plan exécuté sur une PR, sur le code de la branche ; il ne peut **jamais** être appliqué.
3. *Terraform* : remplit une `variable` (comme un `.tfvars`). *Environment* : variable d'environnement du runner (`ARM_*`, `TF_LOG`…).
4. Le runner est détruit après le run : le fichier disparaît, Terraform veut le recréer à chaque run (plan jamais propre), et la clé ne peut pas être récupérée.

## 📝 Correction par rapport à l'ancienne version

- L'ancien lab provoquait l'échec avec `subscription_id = var.subscription_id`. Comme `subscription_id` n'est plus jamais écrit dans le code, l'échec pédagogique vient désormais d'une source de données introuvable : situation réelle et fréquente.
- `local_sensitive_file` sur un runner éphémère produisait un plan jamais propre : corrigé par `write_private_key`.

## 🧯 Pièges observés en session

- 🟥 `terraform.tfvars` commité avec l'IP du stagiaire : sans gravité ici, mais rappeler la règle.
- 🟧 Variables `ARM_*` créées de type *Terraform* : `subscription ID could not be determined`.
- 🟨 Organisation HCP au nom déjà pris : ajouter l'identifiant au nom.
