# 📕 Corrigé formateur — Lab 09

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code final : [`solutions/lab09/`](../solutions/lab09/)

## ⏱️ Déroulé conseillé (45 min)

| Min | Activité |
|---|---|
| 0–15 | Source de données d'image, observation de la recréation (**ne pas appliquer**) |
| 15–25 | `ignore_changes` + `prevent_destroy` |
| 25–35 | Tableau des options `lifecycle` (discussion collective) |
| 35–45 | `client_config`, groupe partagé |

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `Plan: 2 to add, 0 to change, 2 to destroy.` — `source_image_reference` (le champ `version` passe de `"latest"` à `"24.04.…"`) → `# forces replacement` sur les 2 VM. |
| 2 | `ignore_changes = [source_image_reference]` |
| 3 | `Error: Instance cannot be destroyed … has lifecycle.prevent_destroy set`. Le plan **échoue** : rien n'est calculé ni appliqué. |
| 4 | Azure Policy → `ignore_changes = [tags["CostCenter"]]` (ou `[tags]`) · NSG sans coupure → `create_before_destroy` (+ nom unique) · script modifié → `replace_triggered_by` · compte de stockage des états → `prevent_destroy` |
| 5 | `data.azurerm_resource_group.shared.tags` |

**Défi** : après modification du script, `terraform_data.script` change (`~ input`), donc les VM sont `-/+` avec la mention `# replace_triggered_by` / `replaced because of`. Les provisioners se ré-exécutent à la recréation.

```hcl
  lifecycle {
    ignore_changes       = [source_image_reference]
    replace_triggered_by = [terraform_data.script]
  }
```

## ❓ Réponses aux questions

1. `resource` : créé, modifié, détruit par Terraform. `data` : lu à chaque plan, jamais modifié, absent du `destroy`.
2. Avec `"latest"`, la valeur écrite dans le code reste la chaîne `"latest"` : elle ne change jamais, donc aucun écart. La source de données renvoie une **valeur concrète**, qui change à chaque publication.
3. Non : il n'est pas dans l'état comme ressource gérée (il n'est que lu).
4. Bloc `import { to = azurerm_resource_group.shared, id = "/subscriptions/…/resourceGroups/rg-<identity>-shared" }` + un bloc `resource` correspondant (ou `terraform plan -generate-config-out=generated.tf`).

## 📝 Correction par rapport à l'ancienne version

L'ancienne version affirmait que la version lue par `data` était « figée ». C'est faux : elle est **réévaluée à chaque plan**. Sans `ignore_changes`, chaque nouvelle image publiée recrée toutes les VM. C'est désormais le point de départ pédagogique du lab.

## 🧯 Pièges observés en session

- 🟥 Stagiaire qui applique au TODO 1 : 2 VM recréées (~5 min). Pas bloquant.
- 🟧 `prevent_destroy` oublié : le `destroy` de fin de journée échoue. Le rappeler dans le bilan.
- 🟨 `lifecycle` placé dans `source_image_reference` au lieu de la ressource : erreur `Unsupported block type`.
