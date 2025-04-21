# MANPAGE

Voici un **exemple exhaustif de l’exécution du script SSRF PortSwigger**, avec pour chaque challenge :  
- le nom officiel du challenge,  
- le test effectué,  
- et le résultat affiché par le script,  
en cohérence avec la méthodologie PortSwigger et les payloads classiques[1][4][6][7][8].

---

### [Challenge 1] Basic SSRF against the local server

```
------------------------------------------------------
[Challenge 1] Basic SSRF against the local server
[+] Flag ou succès détecté ! (localhost SSRF)
```
*Le script envoie une requête POST sur `/product/stock` avec `stockApi=http://localhost/admin/delete?username=carlos`.  
Le flag ou un message de succès (“Congratulations”, “flag”) est détecté, validant la SSRF locale.*

---

### [Challenge 2] Basic SSRF against another back-end system

```
------------------------------------------------------
[Challenge 2] Basic SSRF against another back-end system
[+] Flag ou succès détecté ! (backend SSRF)
```
*Le script cible l’IP interne typique (ex : `192.168.0.1:8080`) via le paramètre `stockApi`.  
La détection du flag prouve l’accès à un service interne, comme attendu dans ce challenge PortSwigger[4][7].*

---

### [Challenge 3] SSRF with blacklist-based input filter

```
------------------------------------------------------
[Challenge 3] SSRF with blacklist-based input filter
[+] Flag ou succès détecté ! (blacklist bypass SSRF)
```
*Le script tente un contournement de filtre (ex : `127.0.0.1` au lieu de `localhost`, ou variantes).  
Le flag apparaît si le bypass fonctionne, ce qui valide la vulnérabilité malgré la présence d’un filtre côté serveur[8].*

---

### [Challenge 4] SSRF with filter bypass via open redirection vulnerability

```
------------------------------------------------------
[Challenge 4] SSRF with filter bypass via open redirection vulnerability
[+] Flag ou succès détecté ! (open redirect SSRF)
```
*Le script exploite un endpoint open redirect (ex : `/redirect?url=http://localhost/admin/delete?username=carlos`) pour forcer le serveur à rediriger la requête SSRF vers la cible interne.  
La détection du flag valide ce contournement, typique de ce challenge PortSwigger[7][8].*

---

### [Challenge 5] Blind SSRF with out-of-band detection

```
------------------------------------------------------
[Challenge 5] Blind SSRF with out-of-band detection
[*] Vérifiez dans Burp Collaborator si une interaction a eu lieu avec your-collaborator-id.burpcollaborator.net
```
*Le script envoie une requête SSRF vers un domaine Burp Collaborator (ou similaire).  
Le flag n’est pas détecté dans la réponse HTTP : il faut vérifier dans l’interface Collaborator si une interaction DNS ou HTTP a été reçue, ce qui valide la vulnérabilité blind SSRF[2][6][7].*

---

### [Remédiation & Conseils]

```
------------------------------------------------------
[Remédiation & Conseils]
- N'autorisez jamais l'accès aux adresses internes ou localhost via des paramètres utilisateur.
- Implémentez une validation stricte des URLs côté serveur (whitelist, DNS resolution, etc.).
- Désactivez les redirections ouvertes et surveillez les requêtes sortantes.
- Pour les labs PortSwigger, adaptez les endpoints et payloads selon le scénario.
- Documentation PortSwigger : https://portswigger.net/web-security/ssrf
------------------------------------------------------
```

---

### [SYNTHÈSE]

```
------------------------------------------------------
[SYNTHÈSE]
Challenges testés :
1. Basic SSRF against the local server
2. Basic SSRF against another back-end system
3. SSRF with blacklist-based input filter
4. SSRF with filter bypass via open redirection vulnerability
5. Blind SSRF with out-of-band detection
Contrôle automatique du flag ou message de succès (sauf blind SSRF : vérifier Collaborator).
------------------------------------------------------
```

---
