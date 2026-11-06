# 📕 Corrigé formateur — Lab 11

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code : [`solutions/lab11/`](../solutions/lab11/)

## ⏱️ Déroulé conseillé (45 min)

| Min | Activité |
|---|---|
| 0–10 | Bootstrap du stockage |
| 10–25 | `write_state` / `read_state`, configuration partielle |
| 25–35 | Verrouillage à deux terminaux |
| 35–45 | Migration du fil rouge |

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `az storage account blob-service-properties update --account-name "$SA" --resource-group "$RG" --enable-versioning true -o none` |
| 2 | `"lab11/write_state.tfstate"` |
| 3 | `export TF_VAR_tfstate_rg="$TFSTATE_RG" TF_VAR_tfstate_sa="$TFSTATE_SA"` |
| 4 | *Lease state* = **Leased** (*Lease status* = Locked) ; il redevient *Available* après la réponse `no`. |
| 5 | `secondary` lit l'ancien fichier local (déplacé dans `~/backup-tfstate`) : erreur ou valeurs périmées. Version adaptée : [`solutions/lab11/fil-rouge/secondary-main.tf`](../solutions/lab11/fil-rouge/secondary-main.tf) |

**Défi** : Storage Account → Conteneurs → `tfstate` → *Afficher les versions supprimées* → blob → *Versions* → *Rendre la version actuelle*.

## ❓ Réponses aux questions

1. Le backend est initialisé **avant** l'évaluation de la configuration : il doit être connu pour lire l'état, donc avant toute variable.
2. Partage entre membres de l'équipe, verrouillage, durabilité/historique (versioning, redondance), sécurité (accès contrôlé, chiffrement au repos, pas de copie sur les postes).
3. Il copie l'état de l'ancien backend vers le nouveau et reconfigure `.terraform/`. **Aucune** ressource Azure n'est modifiée (d'où `No changes`).

## 🧯 Pièges observés en session

- 🟥 Ancienne version : `SA="sttfstate${IDENTITY}$RANDOM"` dépassait 24 caractères avec un identifiant long. Corrigé : `sttf` + identité (≤ 12) + 6 caractères hex = 22 max.
- 🟧 Le nom du compte se perdait à la fermeture du terminal : d'où `~/.tfstate.env`.
- 🟨 Stagiaire qui a fait `az login` utilisateur : le bootstrap fonctionne aussi, mais le compte appartient alors à l'utilisateur ; pas de problème pour la suite.
