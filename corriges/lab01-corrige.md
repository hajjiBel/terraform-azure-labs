# 📕 Corrigé formateur — Lab 01

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code complet : [`solutions/lab01/`](../solutions/lab01/)

## ⏱️ Déroulé conseillé (30 min)

| Min | Activité |
|---|---|
| 0–10 | Installation Terraform + Azure CLI (souvent déjà fait sur la VM Vagrant) |
| 10–15 | `az login` + démonstration de l'abonnement actif |
| 15–22 | Installation de `~/.azure-tf.env`, explication des 4 variables |
| 22–30 | Test Terraform + bascule SP ↔ az login |

> [!CAUTION]
> Distribuez les fichiers `.azure-tf.env` **individuellement** (message privé, clé USB), jamais sur un canal de groupe.

## ✏️ Réponses aux TODO

**TODO 1**

| Critère | `az login` | Service Principal |
|---|---|---|
| Identité utilisée | votre compte utilisateur | une application dédiée `sp-terraform-<identity>` |
| Interaction humaine | oui (navigateur, MFA) | non |
| Utilisable en CI/CD | ❌ | ✅ |
| Droits | tous les vôtres (souvent Owner) | uniquement ceux attribués (Contributor) |

**TODO 2** — `subscription_id` est lu depuis `ARM_SUBSCRIPTION_ID`. L'écrire en dur rendrait le code non portable (chaque stagiaire, chaque environnement a son abonnement) et habituerait à mettre des identifiants dans le code.

## ✅ Résultat attendu

`terraform apply` affiche `connexion` avec `client_id` = `ARM_CLIENT_ID`. Après `unset ARM_CLIENT_ID ARM_CLIENT_SECRET`, `client_id` devient celui de l'application Azure CLI (`04b07795-8ddb-461a-bbee-02f9e1bf7b46`) et `object_id` celui de l'utilisateur.

## ❓ Réponses aux questions

1. `az login` ouvre un navigateur et demande une interaction (MFA) : un pipeline n'a personne pour la faire.
2. Le provider ne trouve pas d'authentification complète par secret et passe à la méthode suivante (Azure CLI). Si la session CLI n'existe pas : erreur d'authentification. C'est une source classique de « ça marche chez moi ».
3. `create-for-rbac --role … --scopes …` crée une **attribution de rôle** (`Microsoft.Authorization/roleAssignments/write`), réservée à *Owner* / *User Access Administrator*. Contributor ne l'a pas.

## 🧯 Pièges observés en session

- Fichier `.env` copié depuis Windows : `\r` en fin de ligne → secret invalide. Remède : `sed -i 's/\r$//' ~/.azure-tf.env`.
- Deux terminaux VS Code : le second n'a pas fait `source`. D'où l'astuce `~/.bashrc`.
