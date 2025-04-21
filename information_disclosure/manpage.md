# MANPAGE

Voici un **exemple exhaustif de l’exécution du script** pour les challenges *information disclosure* de PortSwigger, illustrant chaque étape (analyse, attaque, contrôle) et les résultats typiques attendus pour chaque vecteur :

---

### 1. Recherche de fichiers et endpoints sensibles

```
------------------------------------------------------
[Analyse] Recherche de fichiers sensibles (robots.txt, backup, debug, versioning)
  [+] Fichier trouvé : https://<your-lab>.web-security-academy.net/robots.txt
User-agent: *
Disallow: /backup
  [+] Fichier trouvé : https://<your-lab>.web-security-academy.net/backup.zip
PK
  [+] Fichier trouvé : https://<your-lab>.web-security-academy.net/.git/config
[core]
	repositoryformatversion = 0
...
```
**Comportement attendu** :  
Le script détecte des fichiers comme `robots.txt`, des backups, ou des dossiers de versioning (`.git`, `.svn`), qui sont des vecteurs classiques de fuite d’information[2][3][5][6].

---

### 2. Recherche d’informations dans le code source HTML

```
------------------------------------------------------
[Analyse] Recherche d’informations dans le code source HTML
<!-- TODO: Remove debug endpoint before production -->
var apiKey = "sk_test_123456789";
<!-- admin panel at /admin-xyz123 -->
```
**Comportement attendu** :  
Le script extrait les commentaires, clés, endpoints ou secrets présents dans le code source HTML, ce qui peut révéler des informations sensibles ou des endpoints cachés[2].

---

### 3. Recherche de messages d’erreur et de verbosité

```
------------------------------------------------------
[Analyse] Recherche de messages d’erreur ou de verbosité
  [+] Message d’erreur ou info sensible détecté pour id=1'
SQL syntax error: unexpected token "'"
  [+] Message d’erreur ou info sensible détecté pour debug=1
Warning: debug mode enabled
```
**Comportement attendu** :  
Le script injecte des paramètres courants pour déclencher des messages d’erreur ou du verbeux, ce qui peut révéler des informations sur la structure interne, la base de données, ou des fonctionnalités cachées[1][2].

---

### 4. Recherche de headers HTTP informatifs

```
------------------------------------------------------
[Analyse] Recherche de headers HTTP informatifs
Server: Apache/2.4.41 (Ubuntu)
X-Powered-By: PHP/7.4.3
X-Debug-Token: 12345abcdef
Set-Cookie: flag=supersecretflag
```
**Comportement attendu** :  
Le script affiche les headers qui peuvent révéler la version du serveur, la techno utilisée, des tokens de debug, ou même des flags ou secrets dans les cookies[2].

---

### 5. Recherche de endpoints cachés dans les scripts JS

```
------------------------------------------------------
[Analyse] Recherche de endpoints cachés dans les scripts JS
apiBaseUrl: "/api/v1/"
const SECRET_TOKEN = "abcdef123456";
endpoint: "/admin-xyz123"
```
**Comportement attendu** :  
Le script télécharge les JS référencés et cherche des endpoints, clés ou secrets codés en dur, ce qui est fréquent dans les labs PortSwigger[2].

---

### 6. Synthèse

```
------------------------------------------------------
[SYNTHÈSE]
1. Recherche de fichiers sensibles et endpoints cachés.
2. Extraction d’informations dans le code source, les erreurs, les headers et les JS.
3. Contrôle automatique : toute fuite affichée doit être validée manuellement (clé, secret, endpoint, debug, etc.).
4. Pour les labs PortSwigger, soumettez la valeur trouvée ou exploitez l’info pour avancer dans le challenge.
- Documentation PortSwigger : https://portswigger.net/web-security/information-disclosure
------------------------------------------------------
```

---
