# WEB Cache deception

1. Identifier un endpoint dynamique contenant des données sensibles (ex : /my-account).  
  - Tester l’ajout d’une extension statique à l’URL (ex : /my-account.css).  
  - Commande curl :  
    `curl -k "https://www.example.com/my-account.css"`  
  - Relancer la commande depuis une session non authentifiée pour vérifier si le contenu privé est servi.  
  - Commande d’analyse :  
    `curl -k -I "https://www.example.com/my-account.css"`  
  - Élément d’analyse : Si la réponse contient des données privées et des headers de cache (ex : X-Cache: HIT), le cache a stocké une page dynamique.  
  - Méthodologie :  
    - Ajouter des extensions (.css, .js, .png) à des endpoints dynamiques.  
    - Vérifier la présence de headers de cache et de contenu privé sur plusieurs sessions/utilisateurs.  
    - Utiliser Burp Suite pour automatiser la détection et observer le comportement différentiel.  
  - Source : https://portswigger.net/web-security/web-cache-deception

2. Tester la confusion de chemin (path confusion) sur un endpoint dynamique.  
  - Ajouter un segment ou un délimiteur à l’URL (ex : /my-account/abc.css ou /profile%2f..%2fmalicious.css).  
  - Commande curl :  
    `curl -k "https://www.example.com/my-account/abc.css"`  
  - Relancer la commande depuis une session différente pour vérifier la présence de données privées.  
  - Commande d’analyse :  
    `curl -k -I "https://www.example.com/my-account/abc.css"`  
  - Élément d’analyse : Si le cache ne distingue pas le segment ajouté, la réponse dynamique peut être servie à d’autres utilisateurs.  
  - Méthodologie :  
    - Injecter des segments ou délimiteurs dans l’URL.  
    - Observer les réponses et headers de cache pour détecter une désynchronisation entre le cache et le backend.  
    - Utiliser des outils comme Burp Suite ou des scripts pour automatiser la détection.  
  - Source : https://portswigger.net/web-security/web-cache-deception

3. Exploiter les règles de cache exact-match ou extension peu commune.  
  - Modifier l’URL pour utiliser un nom de fichier statique ou une extension rare (ex : /my-account/robots.txt ou /profile.php/nonexistent.avif).  
  - Commande curl :  
    `curl -k "https://www.example.com/my-account/robots.txt"`  
  - Relancer la commande pour vérifier la mise en cache (X-Cache: HIT).  
  - Commande d’analyse :  
    `curl -k -I "https://www.example.com/my-account/robots.txt"`  
  - Élément d’analyse : Si la réponse dynamique est stockée sous un nom statique, elle peut être servie à tout utilisateur.  
  - Méthodologie :  
    - Tester des extensions et noms de fichiers variés sur des endpoints dynamiques.  
    - Observer le comportement du cache (miss/hit) et la présence de données sensibles.  
  - Source : https://portswigger.net/web-security/web-cache-deception

4. Vérifier la priorité des règles de cache et des headers Cache-Control.  
  - Commande curl pour observer les headers :  
    `curl -k -I "https://www.example.com/my-account.css"`  
  - Élément d’analyse : Si Cache-Control: no-store n’empêche pas la mise en cache, la configuration est vulnérable.  
  - Méthodologie :  
    - Comparer les headers de cache selon différentes URLs et extensions.  
    - Vérifier si les règles du CDN ou du proxy surchargent les headers applicatifs.  
  - Source : https://portswigger.net/web-security/web-cache-deception

5. Automatiser la détection sur l’ensemble des endpoints.  
  - Utiliser des scripts ou des extensions Burp comme web-cache-deception-scanner pour balayer les chemins et extensions.  
  - Commande d’analyse automatisée (exemple Burp) :  
    Lancer le scanner sur l’application cible et analyser les résultats pour les URLs vulnérables.  
  - Élément d’analyse : Identifier les patterns de cache et les réponses partagées entre utilisateurs.  
  - Méthodologie :  
    - Automatiser les tests sur tous les endpoints dynamiques.  
    - Confirmer manuellement les cas suspects.  
  - Source : https://github.com/PortSwigger/web-cache-deception-scanner

