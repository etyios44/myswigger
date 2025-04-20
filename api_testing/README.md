# API testing

1. Type / Lab : API endpoint discovery and enumeration  
  - Payload d’attaque neutre (exemple brut) : Requêtes GET sur des chemins courants (`/api/users`, `/api/products`, `/api/admin`) ou extraction des endpoints depuis les fichiers JavaScript ou la documentation OpenAPI.  
  - Commande d’attaque (exemple complet) :  
    Utiliser curl, Burp Suite ou des outils comme ffuf pour balayer des chemins probables (ex : `ffuf -u https://site-victime.net/api/FUZZ -w wordlist.txt`).  
  - Commande d’analyse (exemple complet) :  
    Analyser les réponses HTTP (200, 401, 403, 404) et le contenu JSON retourné pour identifier les endpoints actifs et leur comportement.  
  - Élément d’analyse détaillé : Détecter l’existence d’endpoints non documentés, la surface d’attaque réelle de l’API, et les points d’entrée potentiels pour des attaques ultérieures.  
  - Méthodologie détaillée de découverte : Inspecter le front-end, les fichiers JavaScript, la documentation, puis automatiser la découverte par fuzzing et analyse des réponses.  
  - Source : https://portswigger.net/web-security/api-testing

2. Type / Lab : Testing for mass assignment vulnerabilities  
  - Payload d’attaque neutre (exemple brut) : Ajout du paramètre `isAdmin` dans une requête PATCH/PUT sur l’utilisateur :  
    { "username": "wiener", "email": "wiener@example.com", "isAdmin": true }  
  - Commande d’attaque (exemple complet) :  
    curl -X PATCH -H "Content-Type: application/json" -d '{"username":"wiener","email":"wiener@example.com","isAdmin":true}' https://site-victime.net/api/user/1  
  - Commande d’analyse (exemple complet) :  
    Vérifier si le statut admin est activé pour l’utilisateur (`GET /api/user/1`), ou si l’application répond différemment selon la valeur du champ injecté.  
  - Élément d’analyse détaillé : Détecter si des champs sensibles peuvent être modifiés par l’utilisateur via l’API, révélant une vulnérabilité de mass assignment.  
  - Méthodologie détaillée de découverte : Ajouter des champs inattendus ou sensibles dans les requêtes de modification, observer si le serveur les accepte ou les ignore.  
  - Source : https://portswigger.net/web-security/api-testing

3. Type / Lab : Server-side parameter pollution via API  
  - Payload d’attaque neutre (exemple brut) : Injection de plusieurs fois le même paramètre dans la requête (`GET /api/search?user=peter&user=admin`).  
  - Commande d’attaque (exemple complet) :  
    curl "https://site-victime.net/api/search?user=peter&user=admin"  
  - Commande d’analyse (exemple complet) :  
    Comparer la réponse avec celle d’une requête simple, observer si le comportement ou les résultats changent (ex : accès à des données d’un autre utilisateur).  
  - Élément d’analyse détaillé : Détecter si le serveur interprète plusieurs valeurs pour un même paramètre, menant à une pollution de la requête côté serveur.  
  - Méthodologie détaillée de découverte : Injecter des doublons de paramètres, observer les réponses et identifier les variations ou escalades de privilèges.  
  - Source : https://portswigger.net/web-security/api-testing

4. Type / Lab : Testing for improper input validation and injection  
  - Payload d’attaque neutre (exemple brut) : Insertion de caractères spéciaux ou de payloads d’injection (ex : `' OR 1=1--`, `<script>alert(1)</script>`, `{"$ne":""}`) dans les paramètres API.  
  - Commande d’attaque (exemple complet) :  
    curl -X POST -d 'username=admin&password={"$ne":""}' https://site-victime.net/api/login  
  - Commande d’analyse (exemple complet) :  
    Observer si le serveur retourne une erreur, une réponse inattendue, ou accorde un accès non autorisé.  
  - Élément d’analyse détaillé : Détecter l’absence de filtrage et de validation côté serveur, permettant des attaques d’injection ou de contournement d’authentification.  
  - Méthodologie détaillée de découverte : Tester chaque paramètre avec des payloads d’injection, observer les réponses et l’impact sur la logique applicative.  
  - Source : https://portswigger.net/web-security/api-testing

5. Type / Lab : Testing for excessive data exposure  
  - Payload d’attaque neutre (exemple brut) : Requête GET sur un endpoint utilisateur (`/api/users/123`) pour vérifier les champs retournés (ex : email, isAdmin, tokens).  
  - Commande d’attaque (exemple complet) :  
    curl https://site-victime.net/api/users/123  
  - Commande d’analyse (exemple complet) :  
    Analyser la réponse JSON pour repérer des données sensibles ou confidentielles non nécessaires à l’utilisateur courant.  
  - Élément d’analyse détaillé : Détecter si l’API retourne trop d’informations, exposant des données sensibles (PII, tokens, rôles, etc.).  
  - Méthodologie détaillée de découverte : Interroger chaque endpoint, analyser tous les champs retournés, et comparer avec les droits attendus de l’utilisateur.  
  - Source : https://portswigger.net/web-security/api-testing

---

