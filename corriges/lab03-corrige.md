# 📕 Corrigé formateur — Lab 03

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code complet : [`solutions/lab03/`](../solutions/lab03/)

## ⏱️ Déroulé conseillé (20 min)

5 min d'outputs de base, 5 min de commandes `terraform output`, 10 min d'exercices.

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `azurerm_linux_virtual_machine.web.private_ip_address` (ou `azurerm_network_interface.web.private_ip_address`) |
| 2 | `"ssh azureuser@${azurerm_public_ip.web.ip_address}"` |
| 3 | `terraform output` affiche `ssh_command = <sensitive>` ; `-raw` affiche la valeur en clair ; le `grep` montre la valeur **en clair** dans l'état. |

## ✅ Résultat attendu

```text
private_ip  = "10.0.1.4"
public_dns  = "student01-web.francecentral.cloudapp.azure.com"
public_ip   = "20.x.x.x"
ssh_command = "ssh azureuser@20.x.x.x"
```

**Défi** : `curl` / navigateur → *connection refused* (ou délai dépassé) : aucun serveur web n'écoute sur le port 80. Il sera installé au lab 06.

## ❓ Réponses aux questions

1. Un output est une valeur calculée, stockée dans l'état ; il ne correspond à aucun objet Azure.
2. `-raw` : pas de guillemets ni de formatage, la valeur est directement utilisable dans `$(...)`.
3. Non. `sensitive` n'agit que sur l'affichage. L'état doit être protégé (backend chiffré, accès restreint) : c'est l'objet du lab 11.

## 📝 Note sur la version précédente du lab

L'ancienne version utilisait `terraform apply -refresh-only` pour enregistrer les outputs. Cela fonctionne, mais mélange deux notions : `-refresh-only` sert à **accepter une dérive** et il est désormais traité au lab 07 avec un vrai cas de dérive.
