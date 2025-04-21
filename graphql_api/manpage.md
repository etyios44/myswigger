# MANPAGE

Voici un **exemple exhaustif de l’exécution du script** pour les challenges GraphQL API PortSwigger, illustrant chaque phase (découverte, analyse, attaque, contrôle), les résultats typiques, et le comportement attendu :

---

## Lancement du script

```bash
chmod +x script.sh
./script.sh
```

---

### 1. Découverte automatique de l’endpoint GraphQL

```
------------------------------------------------------
[1] Recherche automatique de l’endpoint GraphQL...
  [+] Endpoint GraphQL trouvé : https://<your-lab>.web-security-academy.net/graphql
```
**Comportement attendu** :  
Le script tente plusieurs chemins connus (`/graphql`, `/api/graphql`, etc.) et affiche le premier endpoint qui répond à une requête GraphQL valide (ici, `/graphql`).  
Ceci correspond à la méthodologie de découverte recommandée : fuzzing des endpoints courants et détection de la réponse attendue[7][3].

---

### 2. Test d’introspection

```
------------------------------------------------------
[2] Test d’introspection GraphQL...
  [+] Introspection activée ! Le schéma est exposé.
  [Extrait]:
{"data":{"__schema":{"types":[{"name":"Query"},{"name":"User"},{"name":"Mutation"},{"name":"String"}, ... ]}}
```
**Comportement attendu** :  
Le script envoie une requête d’introspection standard.  
Si la réponse contient `__schema`, l’introspection est activée et le schéma GraphQL est exposé, ce qui facilite la cartographie de l’API et l’attaque[1][4].

---

### 3. Tentative de bypass d’introspection

```
------------------------------------------------------
[3] Tentative de bypass d’introspection (regex naïf)...
  [-] Bypass échoué ou introspection réellement désactivée.
```
**Comportement attendu** :  
Le script tente une variante d’introspection (injection de caractères spéciaux pour contourner un éventuel filtrage naïf côté serveur).  
Si la réponse ne contient pas `__schema`, le bypass ne fonctionne pas : l’introspection est bien désactivée ou filtrée.

---

### 4. Test de requêtes universelles et énumération

```
------------------------------------------------------
[4] Test de requêtes universelles et énumération
  [+] __typename disponible : "__typename":"Query"
  [+] Champ users accessible !
    [Extrait]: {"data":{"users":[{"id":"1","name":"carlos","email":"carlos@..."}]}}
  [+] Champ admin accessible !
    [Extrait]: {"data":{"admin":{"id":"0","name":"administrator","email":"admin@..."}}
```
**Comportement attendu** :  
Le script teste des requêtes génériques (`__typename`, `users`, `admin`, etc.) pour détecter des fuites de données ou des champs accessibles sans restriction.  
S’il trouve des données, il affiche un extrait pour faciliter l’exploitation manuelle ou automatisée[2][3][7].

---

### 5. Contrôle et conseils

```
------------------------------------------------------
[5] Contrôle et conseils
- Si introspection est activée, récupérez le schéma et explorez les queries/mutations sensibles.
- Si elle est désactivée, testez le bypass (caractères spéciaux, GET, x-www-form-urlencoded).
- Testez les requêtes universelles (__typename, users, admin, etc.) pour détecter des fuites de données.
- Pour l’attaque, utilisez Burp Suite (onglet GraphQL) pour manipuler et automatiser les requêtes.
- Pour chaque réponse, vérifiez la présence de données sensibles, d’erreurs ou de comportements inattendus.
- Documentation PortSwigger : https://portswigger.net/web-security/graphql
```
**Comportement attendu** :  
Le script rappelle les étapes manuelles ou avancées à réaliser, selon les résultats précédents. Il recommande l’utilisation de Burp Suite pour l’exploration et l’exploitation poussée[4][8].

---

### 6. Synthèse

```
------------------------------------------------------
[SYNTHÈSE]
1. Découverte automatique de l’endpoint GraphQL.
2. Test d’introspection et bypass éventuel.
3. Requêtes universelles pour énumérer et détecter des fuites.
4. Contrôle des résultats et conseils pour aller plus loin.
------------------------------------------------------
```
