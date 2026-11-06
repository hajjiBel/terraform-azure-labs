# 📕 Corrigé formateur — Lab 04

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Fil rouge : [`solutions/lab04/`](../solutions/lab04/) · Exercice : [`solutions/lab04-exercice/`](../solutions/lab04-exercice/)

## ⏱️ Déroulé conseillé (50 min)

| Min | Activité |
|---|---|
| 0–15 | Cours : types, défauts, validation, priorité des sources |
| 15–30 | Fil rouge : variables + tfvars + observation du plan |
| 30–50 | Exercice (dont le piège `ARM_*`, à faire **en démonstration collective** si le temps manque) |

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `"^[a-z0-9]{3,12}$"` |
| 2 | `value = "ssh ${var.admin_username}@${azurerm_public_ip.web.ip_address}"` |
| 3 | `Plan: 0 to add, 1 to change, 0 to destroy.` sur `azurerm_resource_group.rg` : `+ tags = { "Environment" = "Training" }`. On a **ajouté** `tags = var.tags` au groupe, qui n'en avait pas. Mise à jour sur place, sans danger. Les tags de la VM, eux, sont identiques grâce à `merge()`. |
| 4 | `Standard_B2s` : `-var` l'emporte sur `TF_VAR_`. |
| 5 | voir ci-dessous |
| 6 | Terraform demande `var.ARM_SUBSCRIPTION_ID` : `Enter a value:`. Il aurait fallu `TF_VAR_ARM_SUBSCRIPTION_ID`. |
| 7 | `size = lookup(var.vm_sizes, var.env, "Standard_B1s")` |

```hcl
validation {
  condition     = contains(["francecentral", "westeurope", "northeurope"], var.location)
  error_message = "Région non autorisée pour la formation."
}
```

**Défi** : `os=debian12` → `-/+` sur la VM (`source_image_reference` → `# forces replacement`).

## ❓ Réponses aux questions

1. En CI/CD, les valeurs viennent des secrets/variables du pipeline, injectées comme variables d'environnement sans écrire de fichier. En local, un fichier non versionné évite de tout retaper.
2. Non. `ARM_CLIENT_SECRET` est lu par le provider. Seul `TF_VAR_client_secret` remplit `var.client_secret`.
3. Pendant le `plan` (et le `validate` pour les valeurs connues), avant tout appel à l'API Azure.
4. L'image source d'une VM est immuable : changer d'OS impose de recréer le disque système, donc la VM.

## 🧯 Pièges observés en session

- 🟧 `terraform.tfvars` commité : vérifier le `.gitignore` (`*.tfvars` + `!*.tfvars.example`).
- 🟨 Stagiaire qui a laissé `export TF_VAR_vm_size` : son plan propose un redimensionnement inattendu. Réflexe : `env | grep TF_VAR`.
- 🟨 L'ancienne version du lab mettait les variables en MAJUSCULES (héritage AWS). C'est la source directe de la confusion `ARM_SUBSCRIPTION_ID` / `var.ARM_SUBSCRIPTION_ID` : d'où le TODO 6.
