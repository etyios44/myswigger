# Race conditions

1. Type / Lab : Race condition sur endpoint critique (ex : double dépense, bypass de quota)  
  - Payload d’attaque neutre (exemple brut) : Plusieurs requêtes POST identiques envoyées en parallèle (ex : coupon=FREE100).  
  - Commande d’attaque (exemple complet) :  
    for i in {1..10}; do curl -X POST -d "coupon=FREE100" https://site-victime.net/api/redeem & done; wait  
  - Commande d’analyse (exemple complet) :  
    curl https://site-victime.net/api/balance  
    (Vérifier si le solde ou le nombre de coupons restants a diminué plusieurs fois, indiquant que la même opération a été acceptée simultanément.)  
  - Élément d’analyse détaillé : Détecter si plusieurs actions critiques sont acceptées simultanément, révélant l’absence de verrouillage ou de synchronisation côté serveur.  
  - Méthodologie détaillée de découverte : Identifier un endpoint qui modifie une ressource partagée, envoyer des requêtes concurrentes, puis analyser l’impact sur la ressource (double dépense, dépassement de quota, etc.).  
  - Source : https://portswigger.net/web-security/race-conditions[1]

2. Type / Lab : Race condition sur contournement de limite (ex : brute-force ou rate limit)  
  - Payload d’attaque neutre (exemple brut) : Plusieurs requêtes de connexion envoyées simultanément avec des mots de passe différents pour contourner la protection.  
  - Commande d’attaque (exemple complet) :  
    Utiliser Turbo Intruder ou un script pour envoyer en parallèle une série de tentatives de connexion (ex : username=carlos, password=liste).  
  - Commande d’analyse (exemple complet) :  
    Observer si la protection de limitation de tentatives est contournée et si la connexion à un compte protégé devient possible.  
  - Élément d’analyse détaillé : Détecter si la logique de rate limit peut être contournée par des requêtes concurrentes, permettant un brute-force ou une attaque par dictionnaire.  
  - Méthodologie détaillée de découverte : Identifier un mécanisme de limitation, envoyer des requêtes simultanées, puis vérifier si la restriction est contournée.  
  - Source : https://portswigger.net/web-security/race-conditions/lab-race-conditions-bypassing-rate-limits[3]

3. Type / Lab : Race condition sur upload de fichier (ex : web shell upload)  
  - Payload d’attaque neutre (exemple brut) : Plusieurs requêtes d’upload et d’accès à un fichier envoyées en parallèle.  
  - Commande d’attaque (exemple complet) :  
    Utiliser Turbo Intruder ou un script pour envoyer une requête POST d’upload de fichier suivie de plusieurs requêtes GET pour accéder au fichier, toutes synchronisées.  
  - Commande d’analyse (exemple complet) :  
    Vérifier si le fichier est accessible ou exécutable avant la fin du traitement complet côté serveur.  
  - Élément d’analyse détaillé : Détecter si une course entre upload et accès permet de contourner les contrôles de sécurité ou d’exécuter un web shell.  
  - Méthodologie détaillée de découverte : Synchroniser l’upload et l’accès au fichier, observer si le serveur le traite comme valide avant la fin du processus.  
  - Source : https://portswigger.net/web-security/file-upload/lab-file-upload-web-shell-upload-via-race-condition[6]

4. Type / Lab : Race condition sur validation partielle (ex : inscription sans vérification d’email)  
  - Payload d’attaque neutre (exemple brut) : Plusieurs requêtes d’inscription envoyées en parallèle avec des emails différents.  
  - Commande d’attaque (exemple complet) :  
    Envoyer plusieurs requêtes POST d’inscription avec différentes adresses email, en parallèle, pour tenter de valider un compte sans contrôle.  
  - Commande d’analyse (exemple complet) :  
    Vérifier si un compte est activé sans que l’email de validation ait été reçu ou validé.  
  - Élément d’analyse détaillé : Détecter si un état intermédiaire permet un contournement de la vérification d’email ou d’autres étapes critiques.  
  - Méthodologie détaillée de découverte : Identifier une étape de validation, envoyer des requêtes concurrentes, puis vérifier si la validation est contournée.  
  - Source : https://portswigger.net/web-security/race-conditions/lab-race-conditions-partial-construction[7]

5. Type / Lab : Race condition multi-endpoint (ex : modification d’état via plusieurs endpoints)  
  - Payload d’attaque neutre (exemple brut) : Requêtes simultanées sur différents endpoints impactant une même ressource (ex : ajout au panier + validation commande).  
  - Commande d’attaque (exemple complet) :  
    Envoyer en parallèle des requêtes sur plusieurs endpoints (ex : POST /cart/add-item et POST /checkout) pour provoquer un état inattendu.  
  - Commande d’analyse (exemple complet) :  
    Vérifier si la ressource finale (commande, panier, etc.) reflète un état incohérent ou inattendu (ex : achat à prix réduit).  
  - Élément d’analyse détaillé : Détecter si des opérations concurrentes sur plusieurs endpoints permettent de contourner des validations ou de manipuler l’état d’une ressource.  
  - Méthodologie détaillée de découverte : Identifier des endpoints liés, envoyer des requêtes synchronisées, puis analyser l’état final de la ressource.  
  - Source : https://portswigger.net/web-security/race-conditions/lab-race-conditions-multi-endpoint[8]

---
