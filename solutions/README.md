# 🧩 Solutions — code Terraform de référence

![Formateur](https://img.shields.io/badge/Pour-formateur-dc2626)

Chaque répertoire est l'**état attendu du code à la fin du lab**. Les labs 02 → 09 sont des instantanés successifs du fil rouge : un `diff -r solutions/lab05 solutions/lab06` montre exactement ce que le lab 06 ajoute.

| Répertoire | Lab | Contenu |
|---|---|---|
| [`lab01/`](lab01/) | 🟦 01 | test de connexion (aucune ressource) |
| [`lab02/`](lab02/) | 🟩 02 | première infrastructure, valeurs en dur |
| [`lab03/`](lab03/) | 🟩 03 | + `outputs.tf` |
| [`lab04/`](lab04/) | 🟪 04 | + `variables.tf`, validations, `terraform.tfvars.example` |
| [`lab04-exercice/`](lab04-exercice/) | 🟪 04 | exercice découpage + `lookup` + map d'objets |
| [`lab05/`](lab05/) | 🟪 05 | module `server`, blocs `moved`, module `naming`, clé `tls` |
| [`lab06/`](lab06/) | 🟩 06 | + provisioners, `assets/setup-web.sh` |
| [`lab06-exercice/`](lab06-exercice/) | 🟩 06 | exercice Nginx avec clé fournie |
| [`lab07/`](lab07/) | 🟪 07 | identique au lab 06 + tag `Owner` adopté après la dérive |
| [`lab08/`](lab08/) | 🟧 08 | `for_each` sur `server_names`, `modules/server/moved.tf` (count → for_each) |
| [`lab09/`](lab09/) | 🟦 09 | image lue par `data` + `ignore_changes`, `client_config`, groupe partagé |
| [`lab10/`](lab10/) | 🟪 10 | `primary` / `secondary` (`terraform_remote_state` local) |
| [`lab11/`](lab11/) | 🟪 11 | `bootstrap.sh`, `write_state`, `read_state`, backend du fil rouge |
| [`lab12/`](lab12/) | 🟪 12 | fil rouge prêt pour HCP Terraform (`write_private_key`) |
| [`lab13/`](lab13/) | 🟧 13 | `templatefile` + rôle RBAC (`etape2/` : rendu hors ligne) |
| [`lab14/`](lab14/) | 🟧 14 | Azure + GitHub, règles sortantes conditionnelles |
| [`lab15/`](lab15/) | 🟦 15 | VNet, 6 sous-réseaux, route table, NAT Gateway |
| [`lab16/`](lab16/) | 🟩 16 | lab 15 + VM publique zonale + VM privée |

## ▶️ Utiliser une solution

```bash
cp -r solutions/lab08 /tmp/test-lab08 && cd /tmp/test-lab08
cp terraform.tfvars.example terraform.tfvars   # puis adaptez identity et allowed_ssh_cidr
source ~/.azure-tf.env
terraform init && terraform plan
```

> [!WARNING]
> Les solutions 05 à 09 utilisent `assets/` et `keys/` relatifs à la racine du projet : copiez le répertoire **entier**.

> [!NOTE]
> Toutes les solutions ont été vérifiées syntaxiquement (parseur HCL) et pour le formatage. Lancez `terraform fmt -check -recursive && terraform validate` dans chacune avant la première session pour confirmer avec votre version de Terraform et du provider.
