Voici des exemples exhaustifs d’utilisation du script bash pour les challenges d’API testing de PortSwigger, couvrant chaque fonction du script :

---

## 1. Reconnaissance des endpoints API

**But** : Découvrir les endpoints disponibles, documentés ou non.

**Exécution** :
```bash
./api_testing_audit.sh
```
**Sortie attendue** :
```
[1] Reconnaissance des endpoints API
https://<your-lab>.web-security-academy.net/api => HTTP 200
>> [INFO] Endpoint trouvé : https://<your-lab>.web-security-academy.net/api
https://<your-lab>.web-security-academy.net/api/users => HTTP 200
>> [INFO] Endpoint trouvé : https://<your-lab>.web-security-academy.net/api/users
...
```
**Analyse** : Les endpoints HTTP 200 sont à explorer plus en détail pour les tests suivants.

---

## 2. Test des méthodes HTTP supportées

**But** : Vérifier si des méthodes inattendues (PUT, DELETE, PATCH…) sont acceptées.

**Exécution** :
```bash
./api_testing_audit.sh
```
**Sortie attendue** :
```
[2] Test des méthodes HTTP supportées sur /api/users/123
Méthode GET => HTTP 200
Méthode POST => HTTP 405
Méthode PUT => HTTP 405
Méthode PATCH => HTTP 405
Méthode DELETE => HTTP 405
Méthode OPTIONS => HTTP 200
>> [INFO] Si une méthode inattendue fonctionne, suspectez une surface d'attaque élargie.
```
**Analyse** : Si PATCH ou DELETE retourne 200, la ressource est potentiellement modifiable/supprimable.

---

## 3. Test de mass assignment

**But** : Vérifier si des champs sensibles (ex : isAdmin) peuvent être modifiés.

**Exécution** :
```bash
./api_testing_audit.sh
```
**Sortie attendue** :
```
[3] Test de mass assignment (ex : isAdmin)
Réponse à la tentative de mass assignment : {"username":"wiener","email":"wiener@example.com","isAdmin":true}
>> [ALERTE] Mass assignment détecté : l'utilisateur a pu modifier un champ sensible !
>> PROPOSITION : Filtrer côté serveur les champs modifiables et ignorer les champs sensibles dans le body.
```
**Analyse** : Si la réponse contient `"isAdmin":true`, la faille est présente.

---

## 4. Test de pollution de paramètres (Server-side parameter pollution)

**But** : Tester si le serveur traite plusieurs valeurs pour un même paramètre.

**Exécution** :
```bash
./api_testing_audit.sh
```
**Sortie attendue** :
```
[4] Test de pollution de paramètres côté serveur
Réponse à la requête avec paramètres dupliqués : {"user":"admin",...}
>> [ALERTE] Pollution de paramètres détectée : le serveur traite plusieurs valeurs pour un même paramètre.
>> PROPOSITION : Valider côté serveur qu'un paramètre ne soit présent qu'une seule fois.
```
**Analyse** : Si la réponse montre que le paramètre dupliqué est traité (ex : l’utilisateur admin est retourné), la faille existe.

---

## 5. Test d'exposition excessive de données

**But** : Vérifier si l’API retourne des champs sensibles (tokens, isAdmin, password…).

**Exécution** :
```bash
./api_testing_audit.sh
```
**Sortie attendue** :
```
[5] Test d'exposition excessive de données
Données retournées : {"username":"wiener","email":"wiener@example.com","isAdmin":true,"token":"abcdef"}
>> [ALERTE] Données sensibles exposées dans la réponse !
>> PROPOSITION : Restreindre les champs retournés aux seuls nécessaires côté API.
```
**Analyse** : Toute donnée non strictement nécessaire à l’utilisateur courant doit être masquée côté serveur.

---

## 6. Test de validation des entrées (injection)

**But** : Vérifier si l’API est vulnérable à l’injection (ex : SQL, NoSQL, etc.).

**Exécution** :
```bash
./api_testing_audit.sh
```
**Sortie attendue** :
```
[6] Test de validation des entrées (injection)
Réponse à la tentative d'injection : {"token":"admin-token"}
>> [ALERTE] Injection possible ou absence de filtrage des entrées !
>> PROPOSITION : Valider et filtrer strictement toutes les entrées utilisateur côté serveur.
```
**Analyse** : Si la réponse indique un accès non autorisé ou un comportement anormal, suspectez une injection.

---

## 7. Synthèse et recommandations

**Sortie finale** :
```
------------------------------------------------------
[SYNTHÈSE]
Comparez les réponses ci-dessus pour identifier d'éventuelles failles.
Pour chaque alerte, appliquez les propositions correctives recommandées.
Documentation PortSwigger : https://portswigger.net/web-security/api-testing
------------------------------------------------------
```

---
