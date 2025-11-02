#!/bin/bash

# 📦 Récupération des IPs depuis Terraform
REVIEW_IP=$(terraform output -raw review_ip)
STAGING_IP=$(terraform output -raw staging_ip)
PROD_IP=$(terraform output -raw prod_ip)

# 📁 Chemin où tu veux stocker l’inventory final (racine du projet)
DEST_PATH="../"

# 🧠 Génération du fichier d'inventaire Ansible
cat <<EOF > inventory
[review]
$REVIEW_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/Documents/projet_jenkins/projet_jenkins.pem

[staging]
$STAGING_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/Documents/projet_jenkins/projet_jenkins.pem

[prod]
$PROD_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/Documents/projet_jenkins/projet_jenkins.pem
EOF

# 🚚 Déplacement du fichier à la racine
mv -f inventory "$DEST_PATH"

echo "✅ Inventory Ansible généré et déplacé vers : $DEST_PATH"
cat "$DEST_PATH"
