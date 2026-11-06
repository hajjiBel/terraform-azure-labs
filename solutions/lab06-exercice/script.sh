#!/bin/bash
# attendre la fin du démarrage de la VM
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done
apt-get update
apt-get -y install nginx
systemctl enable --now nginx
