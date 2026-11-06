# 📕 Corrigé formateur — Lab 08

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Code final : [`solutions/lab08/`](../solutions/lab08/)

## ⏱️ Déroulé conseillé (60 min)

| Min | Activité |
|---|---|
| 0–5 | Suppression des `moved` du lab 05 |
| 5–25 | `count` + outputs + apply (~5 min de création) |
| 25–35 | Pilotage depuis la racine + piège de `count` (**plans uniquement**) |
| 35–55 | Migration `for_each` + `moved` + suppression ciblée (plan) |
| 55–60 | Questions ; défi `dynamic` pour les rapides |

> [!TIP]
> Si le temps manque, les étapes 3 et 4.4 se font **en démonstration** sur l'écran du formateur.

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `azurerm_network_interface.web[count.index].id` |
| 2 | `azurerm_linux_virtual_machine.web[*].private_ip_address` |
| 3 | `"ssh -i keys/${var.identity}.pem ${var.admin_username}@${module.server.public_ip[0]}"` et `urls = [for d in module.server.public_dns : "http://${d}"]` |
| 4 | `Plan: 6 to add, 0 to change, 3 to destroy.` Terraform renumérote bien `web` → `web[0]` (pas de destruction pour cela), mais le **nom** change (`vm-web` → `vm-web-1`, idem pip et nic) : `name` force la recréation. |
| 5 | `Plan: 3 to add, 0 to change, 0 to destroy.` (pip, nic, vm de l'index 2). Grâce au tag `Name = "web-${count.index + 1}"`, les VM existantes ne changent pas. |
| 6 | Terraform détruit **l'index 1, donc `vm-web-2`** (et sa pip, sa nic) : avec `count`, on ne retire que **la fin** de la liste. Impossible de cibler `web-1`. |
| 7 | voir [`solutions/lab08/modules/server/main.tf`](../solutions/lab08/modules/server/main.tf) |
| 8 | `Plan: 6 to add, 0 to change, 6 to destroy.` (les adresses `[0]`/`[1]` disparaissent, `["web-1"]`/`["web-2"]` apparaissent) |
| 9 | voir [`solutions/lab08/modules/server/moved.tf`](../solutions/lab08/modules/server/moved.tf) |
| 10 | Seules `pip-web-1`, `nic-web-1`, `vm-web-1` sont détruites : `Plan: 0 to add, 0 to change, 3 to destroy.` `web-2` n'est pas touché. |

**Défi** — `terraform.tfvars` :

```hcl
inbound_rules = {
  SSH  = { port = 22, priority = 100, source = "203.0.113.10/32" }
  HTTP = { port = 80, priority = 110, source = "*" }
}
```

> [!WARNING]
> Ancienne version du lab : la priorité était calculée avec `index(keys(var.inbound_ports), key)`. `keys()` trie par ordre alphabétique : ajouter `HTTPS` décalait la priorité de `SSH`. À éviter.

## ❓ Réponses aux questions

1. Les instances sont identifiées par leur **position** : retirer un élément décale les suivants, qui sont recréés.
2. `for_each` n'accepte qu'une **map** ou un **set** : une liste peut contenir des doublons et n'a pas de clé stable.
3. `module.server.azurerm_linux_virtual_machine.web["web-2"]`. Le nom Azure (`vm-web-2`) n'a pas changé.
4. Pour des copies vraiment interchangeables, ou pour une ressource **optionnelle** : `count = var.enable_x ? 1 : 0`.

## 🧯 Pièges observés en session

- 🟥 Stagiaire qui applique le plan du TODO 8 (sans `moved`) : 6 destructions, ~6 min perdues. Faire relire le résumé à voix haute.
- 🟧 `moved` écrits à la racine avec `module.server.` **et** dans le module : erreur de conflit. Un seul endroit.
- 🟨 Quota : avec 15 stagiaires × 3 VM au TODO 5, des `QuotaExceeded` apparaissent si quelqu'un applique. D'où la consigne « n'appliquez pas ».
