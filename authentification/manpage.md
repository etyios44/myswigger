# MANPAGE

Voici des exemples exhaustifs d’utilisation du script bash pour les challenges d’authentification PortSwigger, couvrant chaque fonction et le type de sortie attendue :

---

## 1. Brute-force (Credential Stuffing)

**But** : Tester si des identifiants faibles ou communs permettent de s’authentifier.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[1] Test de brute-force d'authentification
Tentative wiener:peter -> Échec
Tentative administrator:peter -> Échec
Tentative admin:peter -> Échec
>> [ALERTE] Authentification réussie pour carlos avec peter !
>> PROPOSITION : Implémenter une protection contre le brute-force (CAPTCHA, lockout, délai).
```
**Analyse** : Si un accès est obtenu avec un mot de passe faible pour un utilisateur sensible, la faille est confirmée.

---

## 2. User Enumeration (énumération d’utilisateurs)

**But** : Vérifier si les messages d’erreur permettent de deviner la validité d’un nom d’utilisateur.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[2] Test d'énumération d'utilisateurs
Utilisateur wiener existe probablement (erreur mot de passe) !
Utilisateur administrator existe probablement (erreur mot de passe) !
>> [ALERTE] Message d'erreur distinct pour utilisateur inexistant (unknownuser) !
>> PROPOSITION : Uniformiser les messages d'échec d'authentification.
```
**Analyse** : Si le message diffère selon l’existence du compte, la faille est présente.

---

## 3. Authentication bypass via header personnalisé

**But** : Tester si un header spécial permet de contourner l’authentification.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[3] Test de contournement via header personnalisé (ex: X-Custom-IP-Authorization)
>> [ALERTE] Accès admin obtenu via header X-Custom-IP-Authorization !
>> PROPOSITION : Ne pas se fier à des headers manipulables côté client pour l'authentification.
```
**Analyse** : Si l’accès admin est obtenu, la faille est présente.

---

## 4. Host header attacks (bypass)

**But** : Tester si la manipulation du header Host permet un accès non autorisé.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[4] Test de contournement via Host header
>> [ALERTE] Accès admin obtenu via Host: localhost !
>> PROPOSITION : Valider strictement le header Host côté serveur.
```
**Analyse** : Si l’accès admin est obtenu, la faille est confirmée.

---

## 5. Account lockout (Denial of Service)

**But** : Vérifier si un compte se verrouille après plusieurs tentatives échouées.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[5] Test de verrouillage de compte (DoS)
Pas de verrouillage détecté après plusieurs échecs.
# ou
>> [INFO] Compte verrouillé après plusieurs tentatives.
>> PROPOSITION : Limiter les messages d'erreur et prévoir un mécanisme de déverrouillage sécurisé.
```
**Analyse** : Si le compte est verrouillé, la fonctionnalité est active ; sinon, le compte est vulnérable au brute-force.

---

## 6. HTTP method confusion (ex: TRACE, OPTIONS)

**But** : Vérifier si des méthodes HTTP non standards révèlent des informations sensibles.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[6] Test de méthodes HTTP non standards (TRACE, OPTIONS)
Méthode TRACE : rien de sensible détecté.
Méthode OPTIONS : rien de sensible détecté.
# ou
>> [ALERTE] Méthode TRACE révèle un header ou une information sensible !
>> PROPOSITION : Désactiver les méthodes HTTP inutiles sur le serveur.
```
**Analyse** : Si des informations sensibles sont révélées, la faille est confirmée.

---

## Synthèse finale

**Sortie** :
```
------------------------------------------------------
[SYNTHÈSE]
Comparez les réponses ci-dessus pour identifier d'éventuelles failles d'authentification.
Pour chaque alerte, appliquez les propositions correctives recommandées.
Documentation PortSwigger : https://portswigger.net/web-security/authentication
------------------------------------------------------
```

---

