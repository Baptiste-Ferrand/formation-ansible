#!/bin/bash
# Script de test du déploiement WordPress + MySQL via Ansible
# Génère le fichier logs/execution.txt attendu dans les livrables du TP

set -o pipefail
mkdir -p logs
LOGFILE="logs/execution.txt"

echo "=== TP Ansible - Déploiement WordPress + MySQL ===" > "$LOGFILE"
echo "Date d'exécution : $(date)" >> "$LOGFILE"
echo "" >> "$LOGFILE"

echo ">>> 1. Vérification de la syntaxe du playbook" | tee -a "$LOGFILE"
ansible-playbook playbook.yaml --syntax-check 2>&1 | tee -a "$LOGFILE"

echo "" | tee -a "$LOGFILE"
echo ">>> 2. Test de connectivité (ping) sur tous les hôtes" | tee -a "$LOGFILE"
ansible all -m ping 2>&1 | tee -a "$LOGFILE"

echo "" | tee -a "$LOGFILE"
echo ">>> 3. Affichage de l'inventaire (graph)" | tee -a "$LOGFILE"
ansible-inventory --graph 2>&1 | tee -a "$LOGFILE"

echo "" | tee -a "$LOGFILE"
echo ">>> 4. Exécution en mode --check (dry-run, aucune modification réelle)" | tee -a "$LOGFILE"
ansible-playbook playbook.yaml --check 2>&1 | tee -a "$LOGFILE"

echo "" | tee -a "$LOGFILE"
echo ">>> 5. Exécution réelle du playbook" | tee -a "$LOGFILE"
ansible-playbook playbook.yaml 2>&1 | tee -a "$LOGFILE"

echo "" | tee -a "$LOGFILE"
echo ">>> 6. Vérification finale : test HTTP sur le serveur web (port 80)" | tee -a "$LOGFILE"
WEB_IP=$(ansible-inventory --list | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['serveurweb']['hosts'][0])" 2>/dev/null)
curl -s -o /dev/null -w "HTTP status code: %{http_code}\n" "http://${WEB_IP}" 2>&1 | tee -a "$LOGFILE"

echo "" | tee -a "$LOGFILE"
echo "=== Fin des tests - logs enregistrés dans $LOGFILE ===" | tee -a "$LOGFILE"
