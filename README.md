# Projet CI/CD - Jenkins, Docker, Ansible & Terraform sur AWS

## Objectif

Ce projet personnel a pour but de **mettre en place une chaîne CI/CD complète** permettant de :
- Construire et tester automatiquement une application statique,
- Publier son image Docker sur Docker Hub,
- Déployer cette image sur des serveurs AWS à l’aide d’**Ansible**,
- Gérer l’infrastructure complète (Review, Staging, Production) via **Terraform**.

L’ensemble du pipeline est orchestré par **Jenkins**, avec des validations manuelles avant chaque déploiement en environnement.

---

## Architecture du projet

Le projet est structuré autour de quatre briques principales :

- **Docker** : Conteneurisation de l’application statique.
- **Jenkins** : Orchestration du pipeline CI/CD.
- **Ansible** : Automatisation du déploiement sur les serveurs.
- **Terraform** : Provisionnement de l’infrastructure AWS.

Les environnements créés sont :
- `Review` : pour tester les changements récents.
- `Staging` : pour valider la version avant production.
- `Prod` : environnement final de mise en ligne.

---

## Fonctionnement général

1. **Construction (Build)**  
   Jenkins construit l’image Docker de l’application à partir du Dockerfile.  
   Cela garantit que le même environnement est utilisé partout, de la phase de test à la production.

2. **Test automatique**  
   L’image construite est exécutée localement pour vérifier que l’application répond bien.  
   Jenkins s’assure ainsi que la version est fonctionnelle avant publication.

3. **Publication (Release)**  
   Si le test réussit, l’image est envoyée sur **Docker Hub** avec un tag versionné.  
   Cela permet de centraliser et versionner les images utilisées par les serveurs AWS.

4. **Déploiement (Review → Staging → Prod)**  
   Chaque déploiement est déclenché manuellement depuis Jenkins pour plus de contrôle.  
   Jenkins utilise alors **Ansible** pour :
   - Se connecter au serveur concerné (via SSH et clé privée),
   - Installer Docker (si nécessaire),
   - Supprimer l’ancien conteneur,
   - Télécharger et exécuter la nouvelle image Docker.

5. **Supervision et notifications**  
   À la fin du pipeline, Jenkins envoie automatiquement une notification (ex. via Slack) indiquant le statut du déploiement.

---

## Infrastructure AWS avec Terraform

L’infrastructure cloud est entièrement gérée par **Terraform**.  
À partir d’un simple script de configuration, Terraform crée automatiquement :
- Trois instances EC2 (Review, Staging, Prod),
- Un groupe de sécurité autorisant SSH (port 22) et HTTP (port 80),
- Une clé publique utilisée par Jenkins et Ansible.

Cette approche rend l’infrastructure **reproductible**, **déclarative** et **facile à détruire/recréer** à tout moment.

---

## Déploiement automatisé avec Ansible

Ansible est responsable de la configuration des serveurs créés par Terraform.  
Il installe Docker, s’assure que le service est actif, puis déploie l’application dans un conteneur.  
L’utilisation d’Ansible rend le déploiement **idempotent** :  
même si le playbook est relancé plusieurs fois, le système reste cohérent.

---

## Conteneurisation avec Docker

L’application est une page web statique servie par **Nginx**.  
Elle est copiée dans un conteneur minimaliste, garantissant légèreté et portabilité.  
L’image est ensuite hébergée sur **Docker Hub**, ce qui permet à tous les environnements (Review, Staging, Prod) de récupérer la même version garantie.

---

## Chaîne complète CI/CD

Voici le flux complet automatisé :

1. **Push GitHub** → déclenche le build sur Jenkins.  
2. Jenkins **construit et teste** l’image Docker.  
3. Jenkins **publie** l’image sur Docker Hub.  
4. Jenkins **déploie successivement** sur Review, Staging et Prod via Ansible.  
5. **Slack** notifie le résultat final du pipeline.

Ce processus garantit une livraison continue maîtrisée, reproductible et totalement automatisée.

---

## Sécurité et gestion des clés

Les connexions SSH sont sécurisées grâce à une paire de clés :
- La **clé privée (`projet_jenkins.pem`)** reste stockée localement et utilisée uniquement par Jenkins et Ansible.
- La **clé publique (`projet_jenkins.pub`)** est enregistrée sur AWS par Terraform lors de la création des instances.

Le fichier `.pem` est exclu du dépôt via `.gitignore` pour éviter toute fuite sensible.

---

## Points clés du projet

- **Intégration continue** : chaque modification du code source déclenche automatiquement un build et des tests.  
- **Livraison continue** : le déploiement est automatisé jusqu’en production avec validations humaines.  
- **Infrastructure as Code** : Terraform définit et versionne toute l’infrastructure.  
- **Automatisation complète** : aucune étape manuelle côté serveur, tout passe par Jenkins et Ansible.  
- **Reproductibilité** : le projet peut être recréé de zéro à tout moment avec les mêmes résultats.

---

## Commandes principales

| Action | Commande |
|--------|-----------|
| Initialiser l’infrastructure | `terraform init` |
| Créer les serveurs AWS | `terraform apply` |
| Supprimer l’infrastructure | `terraform destroy` |
| Vérifier les IPs AWS | `terraform output` |
| Tester la connexion Ansible | `ansible -i inventory all -m ping` |
| Lancer le pipeline Jenkins | Exécution manuelle ou push GitHub |

---

## Outils et technologies

| Outil | Rôle |
|-------|------|
| **Jenkins** | Orchestration CI/CD |
| **Docker** | Conteneurisation de l’application |
| **Ansible** | Déploiement automatisé |
| **Terraform** | Création et gestion de l’infrastructure AWS |
| **AWS EC2** | Hébergement des environnements |
| **Slack** | Notifications de pipeline |

---

## Résultat

Au terme du pipeline :
- Une image Docker fonctionnelle est publiée sur Docker Hub,  
- Les trois environnements AWS sont automatiquement mis à jour,  
- Chaque version déployée est testée, validée et traçable,  
- L’ensemble du processus est **100 % automatisé et reproductible**.

---


## Auteur

**Massyl B.**  
Projet personnel d’intégration et de déploiement continu sur AWS.  
**Stack :** Jenkins · Docker · Ansible · Terraform · AWS EC2  

---
