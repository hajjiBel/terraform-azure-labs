# 📕 Corrigé formateur — Lab 05

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code complet : [`solutions/lab05/`](../solutions/lab05/)

## ⏱️ Déroulé conseillé (60 min)

| Min | Activité |
|---|---|
| 0–10 | Cours : module racine / module enfant, entrées / sorties |
| 10–35 | Refactoring + plan sans `moved` (**faire constater le 3 to destroy**) + `moved` |
| 35–45 | Registre + module `naming` |
| 45–60 | Clé TLS, recréation de la VM, SSH |

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `location = var.location` et `resource_group_name = var.resource_group_name` dans la NIC et la VM |
| 2 | `azurerm_linux_virtual_machine.web.private_ip_address` |
| 3 | `azurerm_subnet.web.id` |
| 4 | `value = module.server.public_ip`, `module.server.public_dns`, `module.server.private_ip` ; `ssh_command` utilise `module.server.public_ip` |
| 5 | `from = azurerm_network_interface.web` / `to = module.server.azurerm_network_interface.web` |
| 6 | Des ressources `random_string` **internes au module** naming (état uniquement). Aucune ressource Azure : rien dans le portail. |
| 7 | `"ssh -i keys/${var.identity}.pem ${var.admin_username}@${module.server.public_ip}"` |
| 8 | `module.server.azurerm_linux_virtual_machine.web` est `-/+`, attribut `admin_ssh_key` → `# forces replacement`. Résumé : `Plan: 3 to add, 0 to change, 1 to destroy.` (clé TLS + fichier local + nouvelle VM ; l'ancienne VM détruite). L'IP publique statique est conservée. |

## ✅ Résultat attendu

```text
module.server.azurerm_linux_virtual_machine.web
module.server.azurerm_network_interface.web
module.server.azurerm_public_ip.web
```

**Défi** : avec `name_suffix = "web"`, les noms calculés sont identiques (`pip-web`, `nic-web`, `vm-web`) : aucune différence entre code et état → `No changes`.

## ❓ Réponses aux questions

1. `init` installe les modules (même locaux) dans `.terraform/modules/modules.json` : Terraform doit connaître leur emplacement.
2. Par la racine : output du module A → `module.a.<output>` → argument du module B.
3. `moved` est déclaratif et versionné, revu dans le plan, appliqué partout ; `state mv` est une commande impérative, locale, non tracée.
4. `admin_ssh_key` est immuable sur `azurerm_linux_virtual_machine` (clé injectée à la création).

## 🧯 Pièges observés en session

- 🟥 Stagiaire qui applique le plan sans `moved` : VM recréée, ~3 min perdues. Pas grave, mais à transformer en leçon.
- 🟧 Ressources **copiées** au lieu de **coupées** : erreur de conflit ou doublon. Le message `Moved object still exists` aide.
- 🟨 Version du module `naming` non épinglée : à chaque `init -upgrade`, risque de changement de comportement.
