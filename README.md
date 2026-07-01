# Rendu TP Ansible – Déploiement Web + MySQL

## Choix d’architecture
- 2 serveurs distincts :
  - `serveurweb` : WordPress + Apache (HTTP 80)
  - `serveurdatabase` : MySQL (TCP 3306)
- Ce choix suit la recommandation "un rôle par machine".

## Alternative fonctionnelle
L’énoncé autorise une alternative à Prestashop.  
La solution livrée utilise **WordPress**, conforme à la consigne.

## Contenu du livrable
- `roles/mysql/`
- `roles/wordpress/`
- `playbook.yaml`
- `inventaire.yaml`
- `group_vars/`
- `logs/execution.txt`

## Vérifications réalisées (voir `logs/execution.txt`)
1. `--syntax-check` du playbook
2. `ansible all -m ping`
3. `ansible-inventory --graph`
4. Exécution `--check`
5. Exécution réelle du playbook
6. Re-exécution (idempotence)
7. Test réseau Web -> DB sur `3306`
8. Test HTTP sur le serveur web (redirection WordPress install)