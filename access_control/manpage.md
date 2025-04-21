# MANPAGE

Voici des exemples exhaustifs d’utilisation du script bash d’audit des contrôles d’accès, adaptés aux différents scénarios PortSwigger :

---

## 1. Contrôle d’accès horizontal (IDOR)

- **But** : Vérifier si un utilisateur peut accéder aux données d’un autre utilisateur en modifiant un identifiant.
- **Exemple d’exécution** :

```bash
# Test accès à la ressource d'un autre utilisateur (IDOR)
./access_control_audit.sh

# Résultat attendu si vulnérabilité :
# [ALERTE] Possible IDOR : même réponse pour deux utilisateurs différents !
# PROPOSITION : Implémenter une vérification côté serveur de l'appartenance de la ressource à l'utilisateur authentifié.
```

- **Cas pratique** : Sur un lab PortSwigger, modifiez l’ID dans l’URL (`/api/user/124`) et comparez la réponse pour deux sessions différentes.

---

## 2. Contrôle d’accès vertical (élévation de privilèges)

- **But** : Tester si un utilisateur standard peut accéder à des fonctions réservées à un administrateur.
- **Exemple d’exécution** :

```bash
# Test accès à une page admin avec un compte utilisateur standard
./access_control_audit.sh

# Résultat attendu si vulnérabilité :
# [ALERTE] Accès admin possible avec un compte non privilégié !
# PROPOSITION : Restreindre l'accès à ce chemin aux seuls comptes administrateurs (vérification stricte du rôle).
```

- **Cas pratique** : Sur un lab PortSwigger, tentez l’accès à `/admin` ou `/admin-panel` avec un cookie d’utilisateur standard.

---

## 3. Contrôle d’accès par manipulation de paramètres cachés

- **But** : Vérifier si un utilisateur peut s’attribuer des droits supérieurs en injectant un paramètre (ex : `isAdmin=true`).
- **Exemple d’exécution** :

```bash
# Tentative d'élévation de privilège via paramètre isAdmin
./access_control_audit.sh

# Résultat attendu si vulnérabilité :
# [ALERTE] L'utilisateur peut s'auto-attribuer des droits admin !
# PROPOSITION : Filtrer et ignorer côté serveur toute tentative de modification de rôle par l'utilisateur.
```

- **Cas pratique** : Sur un lab PortSwigger, ajoutez `isAdmin=true` dans la requête de modification de profil et vérifiez la réponse.

---

## 4. Contrôle d’accès sur actions sensibles (suppression, modification)

- **But** : Tester si un utilisateur peut supprimer ou modifier la ressource d’un autre utilisateur.
- **Exemple d’exécution** :

```bash
# Tentative de suppression d'un autre utilisateur
./access_control_audit.sh

# Résultat attendu si vulnérabilité :
# [ALERTE] Un utilisateur peut supprimer le compte d'un autre !
# PROPOSITION : Vérifier côté serveur que l'utilisateur ne peut agir que sur ses propres ressources.
```

- **Cas pratique** : Sur un lab PortSwigger, envoyez une requête DELETE sur `/api/user/124` avec un compte non autorisé.

---

## 5. Contrôle d’accès basé sur la méthode HTTP

- **But** : Vérifier si une action sensible est accessible via une méthode HTTP non prévue (ex : POST au lieu de GET).
- **Exemple d’exécution** :

```bash
# Test accès avec méthode POST sur un endpoint potentiellement restreint
./access_control_audit.sh

# Résultat attendu si vulnérabilité :
# [ALERTE] Endpoint accessible via une méthode inattendue !
# PROPOSITION : Restreindre strictement les méthodes HTTP autorisées sur chaque endpoint.
```

- **Cas pratique** : Sur un lab PortSwigger, essayez d’accéder à un endpoint en variant la méthode HTTP (GET, POST, PUT, DELETE).

---

## 6. Analyse et recommandations

À la fin de l’exécution, le script affiche une synthèse :

- Liste des éventuelles failles détectées.
- Propositions correctives pour chaque type de vulnérabilité.
- Invitation à comparer les réponses pour confirmer les failles.

---

## 7. Utilisation avancée

- **Automatisation** : Lancez le script en boucle sur plusieurs endpoints ou identifiants pour une couverture exhaustive.
- **Intégration Burp Suite** : Utilisez les résultats du script pour cibler les endpoints à tester plus finement avec Burp Suite ou d’autres outils spécialisés[1][7].
- **Exemple de boucle pour IDOR** :

```bash
for id in {100..110}; do
    curl -b "session=..." "https://<lab>.web-security-academy.net/api/user/$id"
done
```

---

## 8. Limites et bonnes pratiques

- Vérifiez que les cookies/session utilisés correspondent bien à des utilisateurs de privilèges différents.
- Interprétez les résultats du script avec prudence : une réponse identique ne signifie pas toujours une faille, surtout si les données sont publiques.
- Consultez la documentation PortSwigger pour approfondir chaque scénario[1].

---

**Ressources utiles** :  
- Documentation PortSwigger : https://portswigger.net/web-security/access-control  
- Top 10 OWASP Broken Access Control : https://github.com/OWASP/Top10/blob/master/2017/fr/0xa5-broken-access-control.md

---

Ce script permet donc de reproduire, automatiser et valider les scénarios classiques de contrôle d’accès des labs PortSwigger, tout en fournissant des propositions correctives adaptées à chaque détection.

Sources
[1] Access control vulnerabilities and privilege escalation - PortSwigger https://portswigger.net/web-security/access-control
[2] What is OS command injection, and how to prevent it? - PortSwigger https://portswigger.net/web-security/os-command-injection
[3] Écrire des Scripts Shell Sécurisés | DevSecOps - Stephane Robert https://blog.stephane-robert.info/docs/admin-serveurs/linux/scripts-shell-securises/
[4] [PDF] Introduction au Pentesting https://perso.univ-lyon1.fr/jean-patrick.gelas/UE_Securite/img/Introduction_au_Pentesting.pdf
[5] PortSwigger SQL injection labs - LinkedIn https://www.linkedin.com/pulse/learning-practicing-sql-injection-bash-scripting-kevin-vanegas
[6] Portswigger Labs Writeups - Ricardo J. Ruiz Fernández https://ricardojoserf.github.io/portswiggerlabs/
[7] Top10/2017/fr/0xa5-broken-access-control.md at master - GitHub https://github.com/OWASP/Top10/blob/master/2017/fr/0xa5-broken-access-control.md
[8] Lab: Remote code execution via web shell upload - PortSwigger https://portswigger.net/web-security/file-upload/lab-file-upload-remote-code-execution-via-web-shell-upload
