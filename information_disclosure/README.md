# Information disclosure

Voici la synthèse des principaux scénarios de **divulgation d’informations (information disclosure)**, chaque cas étant présenté sous forme de liste numérotée et indentée pour chaque étape, avec des exemples et commandes brutes prêtes à l’emploi.

---

**1. Fichiers sensibles exposés**  
  1. Payload d’attaque neutre :  
      Accès à des fichiers tels que .env, .conf, .bak, .log, .sql, .json, backup/config.bak, logs/error.log en testant par exemple https://site-victime.net/.env, https://site-victime.net/backup/config.bak, https://site-victime.net/logs/error.log  
  2. Commande d’attaque :  
      curl https://site-victime.net/.env puis curl https://site-victime.net/backup/config.bak puis curl https://site-victime.net/logs/error.log  
  3. Commande d’analyse :  
      curl -I https://site-victime.net/.env puis file -b <(curl -s https://site-victime.net/.env) puis strings <(curl -s https://site-victime.net/.env)  
  4. Élément d’analyse :  
      Vérifier si le serveur retourne un code 200 et si le contenu contient des identifiants, mots de passe, clés API, chaînes de connexion ou variables d’environnement sensibles qui ne devraient pas être accessibles publiquement  
  5. Méthodologie détaillée :  
      Recenser les extensions de fichiers sensibles, tester l’accès direct à ces chemins sur le serveur cible, puis analyser le contenu obtenu pour confirmer la divulgation d’informations critiques sans authentification  
  6. Source :  
      https://portswigger.net/web-security/information-disclosure/exploiting-common-files

**2. Code source ou fichiers de configuration exposés**  
  1. Payload d’attaque neutre :  
      Accès à des fichiers via download.php?filename=admin/config.php, index.php~ ou config.php.bak en testant https://site-victime.net/download.php?filename=admin/config.php, https://site-victime.net/index.php~, https://site-victime.net/config.php.bak  
  2. Commande d’attaque :  
      curl "https://site-victime.net/download.php?filename=admin/config.php" puis curl https://site-victime.net/index.php~ puis curl https://site-victime.net/config.php.bak  
  3. Commande d’analyse :  
      curl -i "https://site-victime.net/download.php?filename=admin/config.php" puis grep -Ei "password|user|secret|key" <(curl -s "https://site-victime.net/download.php?filename=admin/config.php")  
  4. Élément d’analyse :  
      Vérifier si le code source ou le fichier de configuration retourné contient des commentaires, chemins internes, identifiants, secrets d’API, clés privées ou informations d’architecture qui pourraient faciliter une attaque  
  5. Méthodologie détaillée :  
      Cibler les endpoints ou paramètres permettant le téléchargement de fichiers, tester différentes variantes de noms de fichiers et extensions, puis analyser le contenu récupéré pour repérer toute information confidentielle ou sensible accessible sans restriction  
  6. Source :  
      https://portswigger.net/web-security/information-disclosure/exploiting-backup-files

**3. Informations sensibles dans les scripts JavaScript**  
  1. Payload d’attaque neutre :  
      Analyse de fichiers JavaScript publics comme static/app.js, assets/main.js en testant https://site-victime.net/static/app.js, https://site-victime.net/assets/main.js  
  2. Commande d’attaque :  
      curl https://site-victime.net/static/app.js -o app.js puis curl https://site-victime.net/assets/main.js -o main.js  
  3. Commande d’analyse :  
      grep -E "apiKey|secret|token|password" app.js puis less app.js puis grep -E "apiKey|secret|token|password" main.js  
  4. Élément d’analyse :  
      Vérifier si le code JavaScript contient des clés d’API, tokens, secrets, endpoints internes ou informations d’architecture non documentées accessibles à l’utilisateur final  
  5. Méthodologie détaillée :  
      Lister les fichiers JavaScript publics, les télécharger puis les analyser à la recherche de chaînes sensibles ou d’URL internes, puis tester si ces informations permettent d’accéder à d’autres ressources ou fonctionnalités cachées  
  6. Source :  
      https://portswigger.net/web-security/information-disclosure/exploiting-source-maps

**4. Fuites via moteurs de recherche Google Dorking**  
  1. Payload d’attaque neutre :  
      Recherche Google site:site-victime.net ext:env OR ext:log OR ext:conf OR ext:sql OR ext:bak OR ext:json ou intitle:"index of" site:site-victime.net pour repérer des fichiers sensibles indexés  
  2. Commande d’attaque :  
      Effectuer la requête site:site-victime.net ext:env OR ext:log OR ext:conf OR ext:sql OR ext:bak OR ext:json dans Google puis analyser les liens proposés  
  3. Commande d’analyse :  
      Pour chaque lien trouvé utiliser curl -I URL puis curl -s URL pour vérifier l’accessibilité et le contenu du fichier indexé  
  4. Élément d’analyse :  
      Vérifier si des fichiers sensibles sont indexés par les moteurs de recherche et accessibles publiquement, et si leur contenu contient des identifiants, mots de passe, clés API ou données internes confidentielles  
  5. Méthodologie détaillée :  
      Construire des requêtes Google dorking adaptées, analyser les résultats pour repérer des fichiers ou répertoires exposés, puis tester l’accessibilité et le contenu pour confirmer la divulgation d’informations sensibles  
  6. Source :  
      https://portswigger.net/web-security/information-disclosure/exploiting-search-engines

**5. Scan automatisé d’informations techniques**  
  1. Payload d’attaque neutre :  
      Scan Nmap pour détecter bannières, messages d’erreur, versions logicielles ou chemins internes via nmap -sV --script=banner site-victime.net et nmap -sV --script=http-headers site-victime.net  
  2. Commande d’attaque :  
      nmap -sV --script=banner site-victime.net puis nmap -sV --script=http-headers site-victime.net  
  3. Commande d’analyse :  
      nmap -sV --script=http-enum site-victime.net puis nmap -sV --script=http-config-backup site-victime.net  
  4. Élément d’analyse :  
      Vérifier si les résultats du scan révèlent des versions de logiciels, chemins internes, noms de serveurs, configurations ou fichiers accessibles qui pourraient faciliter une attaque ou une reconnaissance avancée  
  5. Méthodologie détaillée :  
      Scanner les services et ports ouverts avec des outils automatisés, analyser les bannières et en-têtes HTTP pour repérer toute information technique sensible ou non nécessaire, puis évaluer le risque de divulgation pour la sécurité du système  
  6. Source :  
      https://portswigger.net/web-security/information-disclosure

---

