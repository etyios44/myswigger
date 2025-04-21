# MANPAGE

Voici des exemples exhaustifs d’utilisation du script pour les challenges de business logic de PortSwigger, avec analyse des résultats attendus pour chaque fonction, en lien avec les scénarios classiques des labs :

---

## 1. Manipulation de quantité (négative, excessive, zéro)

**But** : Tester si l’application accepte des quantités anormales lors d’un achat (ex : quantité négative, quantité zéro, quantité très élevée).

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[1] Test de manipulation de quantité (négative, excessive, zéro)
Tentative d'achat avec quantité=-10 :
{"error":"Invalid quantity"}
Tentative d'achat avec quantité=0 :
{"error":"Invalid quantity"}
Tentative d'achat avec quantité=9999 :
{"success":true,"credit":-13370000}
>> [ALERTE] Achat possible avec une quantité anormale (9999) !
>> PROPOSITION : Valider côté serveur que la quantité est strictement positive et raisonnable.
```
**Analyse** : Si l’achat passe avec une quantité absurde (ex : overflow, crédit négatif), la faille est présente[3][4][5][6].

---

## 2. Suppression ou absence de paramètres obligatoires

**But** : Vérifier si l’application permet une opération sans tous les paramètres requis.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[2] Test de suppression de paramètres obligatoires
Requête sans productId : {"error":"Missing productId"}
Requête sans quantity : {"error":"Missing quantity"}
```
**Analyse** : Si l’opération aboutit malgré l’absence d’un paramètre, la faille existe (ex : achat sans produit ou sans quantité)[1][5].

---

## 3. Séquence d’étapes inattendue (workflow abuse)

**But** : Tester si l’on peut finaliser un achat sans suivre le workflow prévu (ex : accès direct à l’étape de confirmation).

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[3] Test de séquence d'étapes inattendue (workflow abuse)
Soumission d'une étape finale sans avoir complété les étapes préalables...
Réponse : {"success":true,"order":"confirmed"}
>> [ALERTE] Il est possible de finaliser un achat sans suivre le workflow prévu !
>> PROPOSITION : Implémenter un suivi d'état de session côté serveur pour chaque étape critique.
```
**Analyse** : Si la commande est confirmée sans panier ou paiement, la faille est confirmée[3][5].

---

## 4. Utilisation multiple d’un même coupon ou code cadeau

**But** : Tester si un coupon ou un code cadeau peut être utilisé plusieurs fois.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[4] Test d'utilisation multiple d'un même coupon/carte cadeau
Tentative d'utilisation #1 du code GC-12345 : {"success":true}
Tentative d'utilisation #2 du code GC-12345 : {"success":true}
>> [ALERTE] Le code cadeau/coupon peut être utilisé plusieurs fois !
>> PROPOSITION : Invalider le code côté serveur après la première utilisation.
```
**Analyse** : Si le code fonctionne plusieurs fois, la faille est présente (ex : infinite money logic flaw)[5][6][8].

---

## 5. Transfert de fonds avec montant négatif ou excessif

**But** : Tester si l’on peut transférer un montant négatif ou supérieur au solde.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[5] Test de transfert de fonds avec montant négatif ou excessif
Transfert de -1000 à carlos : {"success":true,"balance":1100}
>> [ALERTE] Transfert possible avec un montant anormal (-1000) !
>> PROPOSITION : Valider côté serveur que le montant est strictement positif et inférieur au solde.
Transfert de 0 à carlos : {"error":"Invalid amount"}
Transfert de 999999 à carlos : {"error":"Insufficient funds"}
```
**Analyse** : Si un transfert négatif augmente le solde ou si un montant excessif passe, la faille est confirmée[5].

---

## 6. Accès concurrent (race condition)

**But** : Vérifier si deux requêtes simultanées permettent d’utiliser un code ou un solde deux fois (double-spend).

**Exécution** (à lancer dans deux terminaux) :
```bash
curl -sk -b "session=..." -d "code=GC-12345" "https://<your-lab>.web-security-academy.net/apply-coupon" &
curl -sk -b "session=..." -d "code=GC-12345" "https://<your-lab>.web-security-academy.net/apply-coupon" &
```
**Sortie attendue** :
```
[6] Test d'accès concurrent (race condition, double-spend)
Lancez deux requêtes simultanées pour utiliser le même code cadeau (nécessite deux terminaux ou & en arrière-plan) :
curl -sk -b "..." -d "code=GC-12345" "https://.../apply-coupon" &
curl -sk -b "..." -d "code=GC-12345" "https://.../apply-coupon" &
>> Analysez si le code est accepté deux fois (double dépense).
```
**Analyse** : Si le code est accepté deux fois, il y a un défaut de synchronisation côté serveur (race condition)[5][6].

---

## Synthèse finale

**Sortie** :
```
------------------------------------------------------
[SYNTHÈSE]
Comparez les réponses ci-dessus pour identifier d'éventuelles failles de logique métier.
Pour chaque alerte, appliquez les propositions correctives recommandées.
Documentation PortSwigger : https://portswigger.net/web-security/logic-flaws
------------------------------------------------------
```

---
