# Essential skills

1. Obfuscating attacks using encodings  
   - Payload d’attaque neutre (exemple brut) : Encoder un script XSS `<script>alert(1)</script>` en `%3Cscript%3Ealert(1)%3C%2Fscript%3E`  
   - Commande d’attaque (exemple complet) : curl -d "q=%3Cscript%3Ealert(1)%3C%2Fscript%3E" https://site-victime.net/search  
   - Commande d’analyse (exemple complet) : Observer dans le navigateur si une alerte apparaît ou si le payload est décodé et exécuté  
   - Élément d’analyse détaillé : Vérifier si l’application décode et interprète les caractères encodés, ce qui permet de contourner les filtres XSS ou d’injection  
   - Méthodologie détaillée de découverte : Encoder le payload (URL, Unicode, Base64…), l’injecter dans différents champs, et observer la réaction de l’application  
   - Source : https://portswigger.net/web-security/essential-skills#obfuscating-attacks-using-encodings

2. Using Burp Scanner during manual testing  
   - Payload d’attaque neutre (exemple brut) : Utiliser un paramètre contrôlable, par exemple `username=wiener`  
   - Commande d’attaque (exemple complet) : Intercepter une requête dans Burp Suite, cibler le paramètre, clic droit > "Scan selected insertion point"  
   - Commande d’analyse (exemple complet) : Examiner le Dashboard de Burp pour repérer les vulnérabilités détectées automatiquement  
   - Élément d’analyse détaillé : Détecter rapidement des failles potentielles sur un paramètre ou point d’injection spécifique sans tester chaque payload manuellement  
   - Méthodologie détaillée de découverte : Identifier un ou plusieurs paramètres suspects, lancer un scan ciblé via Burp Scanner, puis analyser et approfondir manuellement les pistes détectées  
   - Source : https://portswigger.net/web-security/essential-skills#using-burp-scanner-during-manual-testing

3. Scanning non-standard data structures  
   - Payload d’attaque neutre (exemple brut) : Injection dans un objet JSON imbriqué, par exemple `{"user":{"name":"admin'--"}}`  
   - Commande d’attaque (exemple complet) : Dans Burp, intercepter une requête POST JSON, sélectionner la valeur à tester, clic droit > "Scan selected insertion point"  
   - Commande d’analyse (exemple complet) : Surveiller le Dashboard de Burp pour voir si une injection ou un comportement inattendu est détecté dans la structure complexe  
   - Élément d’analyse détaillé : Identifier des points d’injection dans des structures de données non standards, souvent mal validées côté serveur  
   - Méthodologie détaillée de découverte : Définir des points d’injection dans des structures complexes (JSON, XML…), lancer un scan ciblé, puis exploiter manuellement les vulnérabilités révélées  
   - Source : https://portswigger.net/web-security/essential-skills/using-burp-scanner-during-manual-testing/lab-scanning-non-standard-data-structures

4. Identifying unknown vulnerabilities (Mystery lab)  
   - Payload d’attaque neutre (exemple brut) : Injecter des payloads classiques comme `' OR 1=1--` ou `<script>alert(1)</script>` dans différents champs  
   - Commande d’attaque (exemple complet) : Explorer l’application, injecter ces payloads via Burp ou curl, par exemple curl -d "search=' OR 1=1--" https://site-victime.net/search  
   - Commande d’analyse (exemple complet) : Observer les différences de réponse, messages d’erreur, comportements inattendus ou exécution de code  
   - Élément d’analyse détaillé : S’entraîner à détecter et exploiter des failles sans indication préalable, comme en test réel  
   - Méthodologie détaillée de découverte : Approche “black box” : explorer l’application, injecter divers payloads, observer les réponses, puis affiner la recherche selon les indices obtenus  
   - Source : https://portswigger.net/web-security/essential-skills#identifying-unknown-vulnerabilities

---
