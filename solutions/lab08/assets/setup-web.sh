#!/bin/bash
# Installé par Terraform (provisioner remote-exec, lab 06)
set -e
apt-get update
apt-get install -y apache2
systemctl enable --now apache2
echo "<html><h1>Bienvenue sur Apache, déployé par Terraform sur Azure</h1><p>$(hostname)</p></html>" > /var/www/html/index.html
