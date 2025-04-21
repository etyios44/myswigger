# MANPAGE

Voici un **exemple exhaustif de l’exécution du script bash pour tous les challenges race condition PortSwigger**, illustrant chaque étape, le comportement attendu, et la logique de contrôle, en cohérence avec la méthodologie PortSwigger et les différents types de labs :

---

### [Challenge 1] Race condition vulnerability allowing overdraw

```
------------------------------------------------------
[Challenge 1] Race condition vulnerability allowing overdraw
------------------------------------------------------
[Test] Overdraw multiple fois le même montant
  -> 20 requêtes simultanées sur /my-account/transfer
  [+] Succès détecté !
/tmp/race_resp_5.txt:Congratulations, you solved the lab!
```
*Le script lance 20 requêtes POST en parallèle sur `/my-account/transfer`.  
La réponse d’au moins une requête contient “Congratulations, you solved the lab!”, prouvant que la limite a été dépassée via une race condition, comme attendu dans ce challenge PortSwigger[1][4][7].*

---

### [Challenge 2] Race condition vulnerability allowing double purchase

```
------------------------------------------------------
[Challenge 2] Race condition vulnerability allowing double purchase
------------------------------------------------------
[Test] Double achat simultané
  -> 2 requêtes simultanées sur /cart/checkout
  [+] Succès détecté !
/tmp/race_resp_2.txt:Congratulations, you solved the lab!
```
*Le script lance 2 requêtes POST simultanées sur `/cart/checkout`.  
Le flag s’affiche si le double achat a réussi, typique du challenge “double purchase”[1][4].*

---

### [Challenge 3] Bypassing rate limits via race conditions

```
------------------------------------------------------
[Challenge 3] Bypassing rate limits via race conditions
------------------------------------------------------
[Test] Bruteforce simultané (password1)
  -> 5 requêtes simultanées sur /login
  [-] Pas de flag détecté.
[Test] Bruteforce simultané (password2)
  -> 5 requêtes simultanées sur /login
  [-] Pas de flag détecté.
[Test] Bruteforce simultané (password3)
  -> 5 requêtes simultanées sur /login
  [+] Succès détecté !
/tmp/race_resp_13.txt:Congratulations, you solved the lab!
```
*Pour chaque mot de passe, 5 tentatives sont faites en parallèle sur `/login`.  
Le flag apparaît si le bypass du rate limit fonctionne, comme dans le lab “Bypassing rate limits via race conditions”[1][4].*

---

### [Challenge 4] Partial construction race conditions

```
------------------------------------------------------
[Challenge 4] Partial construction race conditions
------------------------------------------------------
[Test] Création de compte simultanée
  -> 5 requêtes simultanées sur /register
  [+] Succès détecté !
/tmp/race_resp_4.txt:Congratulations, you solved the lab!
```
*Le script tente 5 inscriptions simultanées sur `/register`.  
La réussite est détectée si le flag s’affiche, typique du challenge “Partial construction race conditions”[1][4].*

---

### [Challenge 5] Multi-endpoint race conditions

```
------------------------------------------------------
[Challenge 5] Multi-endpoint race conditions
------------------------------------------------------
[Test] Multi-endpoint : panier + paiement
  [+] Succès détecté !
/tmp/race_cart.txt:Congratulations, you solved the lab!
```
*Le script lance en parallèle une requête d’ajout au panier et une de paiement.  
Le flag apparaît si la synchronisation permet de contourner une logique métier, comme dans le lab “Multi-endpoint race conditions”[1][4][5].*

---

### [Challenge 6] Web shell upload via race condition

```
------------------------------------------------------
[Challenge 6] Web shell upload via race condition
------------------------------------------------------
  [+] Succès détecté !
/tmp/race_upload.txt:Congratulations, you solved the lab!
```
*Le script lance simultanément un upload de fichier et un renommage.  
Si le flag apparaît, la race condition a permis d’uploader un shell, comme dans le lab “Web shell upload via race condition”[2][6].*

---

### [Remédiation & Conseils]

```
------------------------------------------------------
[Remédiation & Conseils]
- Utilisez des verrous transactionnels côté serveur (atomicité, mutex, etc.).
- Ne faites jamais confiance à l'ordre ou l'unicité des requêtes HTTP.
- Pour les labs PortSwigger, adaptez les endpoints, données et threads selon le scénario.
- Documentation PortSwigger : https://portswigger.net/web-security/race-conditions
------------------------------------------------------
```

---

### [SYNTHÈSE]

```
------------------------------------------------------
[SYNTHÈSE]
Challenges testés :
1. Race condition vulnerability allowing overdraw
2. Race condition vulnerability allowing double purchase
3. Bypassing rate limits via race conditions
4. Partial construction race conditions
5. Multi-endpoint race conditions
6. Web shell upload via race condition
Attaque par requêtes simultanées, détection automatique du flag ou message de succès.
------------------------------------------------------
```

---
