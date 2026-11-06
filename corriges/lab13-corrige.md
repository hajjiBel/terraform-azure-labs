# 📕 Corrigé formateur — Lab 13

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code : [`solutions/lab13/`](../solutions/lab13/) (étapes 1-2 : [`solutions/lab13/etape2/`](../solutions/lab13/etape2/))

> [!CAUTION]
> **Préparation obligatoire** : [`formateur/creer-sp.sh`](../formateur/creer-sp.sh) crée `rg-<identity>-lab13` et donne au SP *User Access Administrator* **sur ce seul groupe**. Sans cela, l'étape 3 échoue (`AuthorizationFailed`).
> **Plan B** si la préparation est impossible : faire les étapes 1-2 en autonomie, puis l'étape 3 **en démonstration** avec votre compte Owner.

## ⏱️ Déroulé conseillé (40 min)

| Min | Activité |
|---|---|
| 0–15 | Modèle + rendu hors ligne |
| 15–30 | Stockage, rôle, attribution |
| 30–40 | Test RBAC (prévoir la propagation) + destroy |

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `Error: Invalid function argument … vars map does not contain key "owner_id"` (référencée dans le modèle). |
| 2 | `data.azurerm_resource_group.lab13.id` |
| 3 | `local.role.DataActions` |
| 4 | `Plan: 5 to add, 0 to change, 0 to destroy.` (random_string, storage account, container, role definition, role assignment). Le groupe est lu par une **source de données** : il n'est ni créé ni détruit. |

**Défi** : dans le modèle, `"DataActions": ${jsonencode(data_actions)},` et dans l'appel `data_actions = ["Microsoft.Storage/…/blobs/read"]`.

## ❓ Réponses aux questions

1. `templatefile` s'exécute dans une portée isolée : seules les clés de la map sont visibles. Cela rend le modèle réutilisable et explicite.
2. `Actions` : plan de contrôle (ARM, gestion des ressources). `DataActions` : plan de données (contenu des blobs, files, queues).
3. Contributor exclut explicitement `Microsoft.Authorization/*/Write` (`NotActions`) : il ne peut ni créer de rôle ni attribuer de droits, sinon il pourrait s'élever lui-même au rang d'Owner.
4. `uuid()` est réévalué à chaque plan : le nom change à chaque fois, d'où une recréation permanente. `random_string` est stocké dans l'état.

## 🧯 Pièges observés en session

- 🟥 Ancienne version : le lab créait son propre groupe et exigeait Owner sur l'abonnement : bloquant en abonnement partagé.
- 🟧 Test fait avec `az login` **utilisateur** alors que le rôle a été attribué au **SP** : `not authorized`. D'où le `az login --service-principal`.
- 🟨 `terraform destroy` puis nouveau `apply` immédiat : le nom du rôle personnalisé peut rester réservé quelques minutes (`RoleDefinitionWithSameNameExists`). Attendre ou changer `role_name`.
