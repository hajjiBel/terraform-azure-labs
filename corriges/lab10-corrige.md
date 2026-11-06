# 📕 Corrigé formateur — Lab 10

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code : [`solutions/lab10/`](../solutions/lab10/)

## ⏱️ Déroulé conseillé (20 min)

10 min pour `primary` / `secondary`, 5 min pour le fil rouge, 5 min de discussion sur les limites de l'état local.

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `"../primary/terraform.tfstate"` |
| 2 | `data.terraform_remote_state.fil_rouge.outputs.public_ip` (une map `web-1` / `web-2` depuis le lab 08) |

**Défi** :

```hcl
output "image_version_ou_defaut" {
  value = try(data.terraform_remote_state.fil_rouge.outputs.image_version, "inconnue")
}
```

## ❓ Réponses aux questions

1. Par conception : les outputs sont l'interface publique d'un projet. Exposer les ressources rendrait les projets dépendants de leurs détails internes.
2. Pas de partage (chacun son fichier), pas de verrouillage (deux `apply` simultanés corrompent l'état), risque de perte (disque, `rm`), secrets en clair sur un poste, aucun historique.
3. L'état contient **toutes** les valeurs, y compris sensibles (clé privée TLS, mots de passe générés) : `terraform_remote_state` lit le fichier entier, même s'il n'expose que les outputs.

## 🧯 Pièges observés en session

- 🟧 `cd $_` après `mkdir -p …/primary && cd $_` : fonctionne en bash, pas en `sh`. Sur la VM, c'est bash.
- 🟨 Stagiaire qui a détruit le fil rouge : l'étape 3 renvoie des outputs vides. Le faire avec l'état d'un voisin (copie) ou passer.
