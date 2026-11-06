# 📕 Corrigé formateur — Lab 06

![Formateur](https://img.shields.io/badge/Corrigé-formateur-dc2626) · Fil rouge : [`solutions/lab06/`](../solutions/lab06/) · Exercice : [`solutions/lab06-exercice/`](../solutions/lab06-exercice/)

## ⏱️ Déroulé conseillé (45 min)

| Min | Activité |
|---|---|
| 0–20 | Connection + provisioners + `-replace` (la recréation + Apache prend ~4 min) |
| 20–40 | Exercice Nginx |
| 40–45 | Comparaison `custom_data` |

## ✏️ Réponses aux TODO

| TODO | Réponse |
|---|---|
| 1 | `var.private_key` |
| 2 | `"sudo bash /tmp/assets/setup-web.sh"` |
| 3 | `Apply complete! Resources: 0 added, 0 changed, 0 destroyed.` (+ l'output `url` si ajouté). Les provisioners ne font pas partie de l'état de la ressource : les ajouter ne crée aucune différence entre code et état. Ils ne s'exécutent qu'à la **création**. |
| 4 | voir [`solutions/lab06-exercice/instance.tf`](../solutions/lab06-exercice/instance.tf). Comme la VM existe déjà : `terraform apply -replace=azurerm_linux_virtual_machine.example`. |

**Défi** : le plan affiche `-/+` sur la VM, `custom_data` → `# forces replacement`. Vérification : `ssh … 'cloud-init status; tail /var/log/cloud-init-output.log'`, puis `curl`.

## ❓ Réponses aux questions

1. Une ressource ne peut pas se référencer par son adresse dans sa propre définition (cycle) ; `self` est la seule façon de lire ses propres attributs dans `connection` et les provisioners.
2. Elle est marquée **tainted** : le prochain `apply` la détruit et la recrée.
3. Pas de SSH depuis Terraform (pas de port 22 ouvert à l'outil, pas de clé à manipuler) ; idempotent et natif à l'image ; fonctionne aussi avec les VMSS et l'autoscaling ; le cycle de vie est clair (changer le script = nouvelle VM).

## 🧯 Pièges observés en session

- 🟥 IP du poste changée entre deux labs (Wi-Fi) : provisioner en timeout → VM tainted. Toujours vérifier `allowed_ssh_cidr`.
- 🟧 `assets/` créé dans `modules/server/` au lieu de la racine : `path.root` ne le trouve pas.
- 🟨 Les labs 12 (HCP Terraform) se connectent en SSH **depuis les runners HCP** : il faudra alors ouvrir le port 22 à Internet. À anticiper dans le discours.
