# 📕 Corrigé formateur — Lab 02

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code complet : [`solutions/lab02/`](../solutions/lab02/)

## ⏱️ Déroulé conseillé (60 min)

| Min | Activité |
|---|---|
| 0–10 | `.gitignore`, provider, groupe de ressources, `init` / `plan` / `apply` |
| 10–35 | Réseau + VM (la création de la VM prend 1 à 2 min) |
| 35–45 | Connexion SSH |
| 45–60 | Tags, expériences `~` / `-/+`, questions |

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `"<MON_IP>/32"`, ex. `"203.0.113.10/32"` (résultat de `curl -s ifconfig.me` + `/32`) |
| 2 | `azurerm_subnet.web.id` |
| 3 | `azurerm_public_ip.web.id` |
| 4 | `Plan: 7 to add, 0 to change, 0 to destroy.` Le groupe de ressources existe déjà depuis l'étape 2 : il est dans l'état et ne change pas. Total dans l'état ensuite : **8**. |
| 5 | `admin_username` (`# forces replacement`). Un compte administrateur ne peut pas être renommé sur une VM existante. |

## ✅ Résultats attendus

- Défi HTTPS : `~ update in-place` sur `azurerm_network_security_group.web` (les blocs `security_rule` intégrés se modifient sur place).
- `terraform state list` :

```text
azurerm_linux_virtual_machine.web
azurerm_network_interface.web
azurerm_network_security_group.web
azurerm_public_ip.web
azurerm_resource_group.rg
azurerm_subnet.web
azurerm_subnet_network_security_group_association.web
azurerm_virtual_network.vnet
```

## ❓ Réponses aux questions

1. `.terraform/` : providers et modules téléchargés (régénérable, **non versionné**). `.terraform.lock.hcl` : versions et empreintes exactes des providers (**versionné**).
2. Le subnet référence `azurerm_virtual_network.vnet.name` : la référence crée une arête dans le graphe de dépendances.
3. `~` : l'API permet la modification (tags, taille). `-/+` : l'attribut est immuable côté Azure (`admin_username`, `name`, `location`).
4. Portabilité (un abonnement par stagiaire / environnement) et hygiène : aucun identifiant dans le code.

## 🧯 Pièges observés en session

- 🟥 Stagiaire derrière un NAT d'entreprise dont l'IP change : SSH en timeout. Faire vérifier `curl -s ifconfig.me` avant chaque `apply`.
- 🟧 `domain_name_label` en majuscules ou avec `_` : refusé par Azure. C'est pourquoi `<identity>` est en `[a-z0-9]`.
- 🟨 Certains stagiaires appliquent l'expérience `admin_username` : la VM est recréée (2 min perdues, mais excellente démonstration). La clé SSH reste valable si `admin_ssh_key.username` a été remis à l'identique.
