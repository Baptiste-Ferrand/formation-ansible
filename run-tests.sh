#!/bin/bash
set -euo pipefail

mkdir -p logs
LOGFILE="logs/execution.txt"
PLAYBOOK="playbook.yaml"
INVENTORY="inventaire.yaml"

{
  echo "=== TP Ansible - Déploiement WordPress + MySQL ==="
  echo "Date d'exécution : $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo
  echo "Playbook   : $PLAYBOOK"
  echo "Inventaire : $INVENTORY"
  echo
} > "$LOGFILE"

run() {
  echo ">>> $*" | tee -a "$LOGFILE"
  eval "$*" 2>&1 | tee -a "$LOGFILE"
  echo | tee -a "$LOGFILE"
}

run "ansible-playbook -i $INVENTORY $PLAYBOOK --syntax-check"
run "ansible -i $INVENTORY all -m ping"
run "ansible-inventory -i $INVENTORY --graph"

# Dry-run
run "ansible-playbook -i $INVENTORY $PLAYBOOK --check"

# Run 1
run "ansible-playbook -i $INVENTORY $PLAYBOOK"

# Run 2 (preuve d'idempotence)
run "ansible-playbook -i $INVENTORY $PLAYBOOK"

# Récupération IP privée DB depuis inventory
DB_IP=$(ansible-inventory -i "$INVENTORY" --host cible2.liora.fr | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('private_ip',''))")
WEB_HOST="cible1.liora.fr"

# Test réseau Web -> DB:3306
run "ansible -i $INVENTORY $WEB_HOST -m shell -a 'nc -zv $DB_IP 3306'"

# Test HTTP depuis machine de contrôle (IP publique web)
WEB_PUBLIC_IP=$(ansible-inventory -i "$INVENTORY" --host "$WEB_HOST" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('ansible_host',''))")
run "curl -I --max-time 10 http://$WEB_PUBLIC_IP"

echo "=== Fin des tests - logs enregistrés dans $LOGFILE ===" | tee -a "$LOGFILE"