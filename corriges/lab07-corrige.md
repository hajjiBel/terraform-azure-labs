# 📕 Corrigé formateur — Lab 07

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code final : [`solutions/lab07/`](../solutions/lab07/)

## ⏱️ Déroulé conseillé (60 min)

| Min | Activité |
|---|---|
| 0–15 | Console, graph, state |
| 15–40 | 🔥 Dérive : simulation, lecture, décisions (**cœur du lab**) |
| 40–50 | Plan enregistré + plan obsolète |
| 50–60 | `-replace`, `fmt`, `validate`, questions |

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `[for i in range(1, 4) : cidrsubnet("10.0.0.0/16", 8, i)]` → `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` |
| 2 | groupe de ressources → VNet → subnet → module `server` (NIC → VM). Le NSG et l'association pointent aussi vers le subnet. |
| 3 | VM : `~ tags` → **suppression** du tag `Owner` (le code ne le contient pas). NSG : `~` → **recréation de la règle** `Allow-HTTP`. Résumé : `Plan: 0 to add, 2 to change, 0 to destroy.` |
| 4 | `terraform apply` restaure la règle. Pour le tag : `tags = merge(var.tags, { Owner = "collegue" })` dans l'appel `module "server"`. Le groupe de ressources utilise `var.tags` directement : il n'est pas concerné. |
| 5 | `Error: Saved plan is stale` — le plan a été calculé sur un état (serial) qui n'existe plus. Appliquer un plan obsolète pourrait écraser des changements faits entre-temps. |

**Étape 6, adresse fausse** : Terraform signale que l'adresse ne correspond à aucune ressource (avertissement ou erreur selon la version) et n'effectue aucun remplacement. Depuis le lab 05, la VM est dans `module.server`.

**Défi** : `plan` propose de **recréer** `azurerm_subnet_network_security_group_association.web` (`+ create`), car la ressource a disparu de la réalité. `plan -refresh-only` montre qu'elle sera **retirée de l'état**.

## ❓ Réponses aux questions

1. `plan` compare le **code** à la réalité et propose des actions ; `-refresh-only` compare l'**état** à la réalité et ne propose que de mettre l'état à jour.
2. `apply -refresh-only` met l'état en conformité avec la réalité, mais le code est inchangé : code ≠ réalité, donc des actions sont toujours proposées.
3. Ce qui a été relu et approuvé est exactement ce qui sera exécuté ; entre deux `plan`, la réalité ou le code peuvent avoir changé.
4. Il vérifie le formatage sans réécrire et renvoie un code d'erreur : la CI échoue si quelqu'un a poussé du code non formaté.

## 🧯 Pièges observés en session

- 🟧 `az vm update --set tags.Owner=…` sur une VM en cours de provisionnement : erreur 409. Attendre la fin de l'apply.
- 🟨 Le second terminal n'a pas `source ~/.azure-tf.env` : erreur d'authentification au lieu du plan obsolète.
- 🟨 `terraform console` verrouille l'état : si un stagiaire laisse une console ouverte, l'`apply` de l'autre terminal attend le verrou.
