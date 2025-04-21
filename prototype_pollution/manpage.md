# MANPAGE

Voici un **exemple exhaustif de l’exécution du script prototype pollution PortSwigger** (version avec noms de challenges), couvrant les principaux scénarios des labs server-side : injection via `__proto__`, `constructor`, `prototype`, et gadgets, avec contrôle du succès et nettoyage automatique.  
Chaque étape correspond à un challenge officiel PortSwigger et illustre le comportement attendu[1][3][6].

---

### [Challenge 1] Server-side prototype pollution via __proto__

```
------------------------------------------------------
[Challenge 1] Server-side prototype pollution via __proto__ (PortSwigger: 'Server-side prototype pollution via __proto__')
  [Test] Payload: {"__proto__":{"status":510}}
  [+] Pollution détectée via __proto__.status
------------------------------------------------------
```
*Le script injecte `{"__proto__":{"status":510}}` via POST.  
Le serveur modifie son comportement : par exemple, le code HTTP ou le champ `statusCode` dans la réponse passe à 510, preuve que la pollution a fonctionné[1][3].*

---

### [Challenge 2] Server-side prototype pollution via constructor

```
------------------------------------------------------
[Challenge 2] Server-side prototype pollution via constructor (PortSwigger: 'Server-side prototype pollution via constructor')
  [Test] Payload: {"constructor":{"status":510}}
  [-] Aucun effet détecté via constructor.
------------------------------------------------------
```
*Le script tente la pollution via `constructor`.  
Aucun changement observé : le serveur n’est pas vulnérable à ce vecteur sur ce lab.*

---

### [Challenge 3] Server-side prototype pollution via prototype

```
------------------------------------------------------
[Challenge 3] Server-side prototype pollution via prototype (PortSwigger: 'Server-side prototype pollution via prototype')
  [Test] Payload: {"prototype":{"status":510}}
  [-] Aucun effet détecté via prototype.
------------------------------------------------------
```
*Le script teste la pollution via `prototype`.  
Aucun effet détecté, ce vecteur n’est pas exploitable ici.*

---

### [Challenge 4] Server-side prototype pollution via gadget property

```
------------------------------------------------------
[Challenge 4] Server-side prototype pollution via gadget property (PortSwigger: 'Server-side prototype pollution using gadget property')
  [Test] Payload: {"__proto__":{"polluted":"polluted"}}
  [+] Pollution détectée via gadget property polluted
------------------------------------------------------
```
*Le script injecte un gadget (`polluted`) via `__proto__`.  
La réponse contient la chaîne `"polluted"`, indiquant que la propriété a bien été polluée et exploitée comme gadget (technique recommandée par PortSwigger pour détecter la pollution même sans effet direct sur le code HTTP[1][5][6]).*

---

### [Remédiation & Conseils]

```
------------------------------------------------------
[Remédiation & Conseils]
- Filtrez les clés __proto__, prototype, constructor dans tous les merges/extends d'objets.
- Utilisez Object.create(null) pour éviter l'héritage du prototype global.
- Appliquez les recommandations PortSwigger : https://portswigger.net/web-security/prototype-pollution/server-side
------------------------------------------------------
```

---

### [SYNTHÈSE]

```
------------------------------------------------------
[SYNTHÈSE]
Challenges testés :
1. Server-side prototype pollution via __proto__
2. Server-side prototype pollution via constructor
3. Server-side prototype pollution via prototype
4. Server-side prototype pollution using gadget property
Tous les tests sont non destructifs, avec nettoyage automatique après test.
------------------------------------------------------
```

---
