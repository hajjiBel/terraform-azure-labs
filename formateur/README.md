# 🛠️ Guide formateur — préparation de la session

![Rôle](https://img.shields.io/badge/Pour-formateur-dc2626) ![Droits](https://img.shields.io/badge/Droits%20requis-Owner%20de%20l'abonnement-7c3aed)

> [!CAUTION]
> Les stagiaires **ne peuvent pas** créer eux-mêmes leur Service Principal : `az ad sp create-for-rbac --role … --scopes …` crée une **attribution de rôle**, ce qui exige *Owner* ou *User Access Administrator*, et l'enregistrement d'applications Entra ID est souvent interdit aux utilisateurs. C'est vous qui les créez.

## 📋 Check-list

| Quand | Action | Script |
|---|---|---|
| 🟦 J‑7 | Lister les identifiants des stagiaires dans `formateur/stagiaires.txt` (un par ligne, `[a-z0-9]{3,12}`) | — |
| 🟦 J‑7 | Vérifier les quotas vCPU et IP publiques de la région | [`verifier-quotas.sh`](verifier-quotas.sh) |
| 🟧 J‑7 | Demander une hausse de quota si besoin (portail → *Quotas*) | — |
| 🟩 J‑2 | Créer les SP, les fichiers `.azure-tf.env` et les RG du lab 13 | [`creer-sp.sh`](creer-sp.sh) |
| 🟩 J‑1 | Tester un SP de bout en bout (lab 01 + lab 02) | — |
| 🟪 J0 | Distribuer à chaque stagiaire **son** fichier `formateur/out/<identity>.azure-tf.env` (canal privé) | — |
| 🟥 Fin J2 | Supprimer tous les groupes de ressources, rôles personnalisés et SP | [`nettoyage-formateur.sh`](nettoyage-formateur.sh) |

## 📐 Dimensionnement

Pic de consommation par stagiaire : **lab 08** (3 VM B1s = 3 vCPU) et **lab 16** (2 VM).

| Stagiaires | vCPU famille B nécessaires | IP publiques Standard |
|---|---|---|
| 10 | 30 | ~40 |
| 15 | 45 | ~60 |
| 20 | 60 | ~80 |

```bash
bash formateur/verifier-quotas.sh francecentral 15
```

> [!TIP]
> Si le quota ne peut pas être augmenté, imposez `num_webs = 2` au lab 08 et faites détruire le fil rouge avant le lab 14.

## 🔐 Droits accordés à chaque SP

| SP | Rôle | Portée | Pourquoi |
|---|---|---|---|
| `sp-terraform-<identity>` | Contributor | abonnement | les labs créent leurs propres groupes de ressources |
| `sp-terraform-<identity>` | User Access Administrator | `rg-<identity>-lab13` uniquement | lab 13 : rôle personnalisé + attribution |

> [!WARNING]
> Avec *Contributor* sur l'abonnement, un stagiaire **peut** supprimer le groupe de ressources d'un autre. Annoncez-le, et rappelez la règle : on ne touche qu'aux `rg-<son identity>-*`.

## 🧯 Problèmes fréquents le jour J

| Symptôme | Cause | Remède |
|---|---|---|
| `SkuNotAvailable` sur la VM | B1s indisponible dans la région/zone | `vm_size = "Standard_B2ats_v2"` ou autre région |
| `QuotaExceeded` / `OperationNotAllowed … cores` | quota vCPU atteint | détruire des VM, réduire `num_webs` |
| `AuthorizationFailed … roleAssignments/write` (lab 13) | RG du lab 13 non préparé | relancer `creer-sp.sh` pour ce stagiaire |
| `AADSTS7000215: Invalid client secret` | secret mal copié | `az ad sp credential reset --id <appId>` puis redistribuer |
