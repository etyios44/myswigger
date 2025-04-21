# MANPAGE

Voici un **exemple exhaustif de l’exécution du script** pour tous les challenges file upload PortSwigger, avec le détail des étapes d’analyse, d’attaque et de contrôle, et les résultats attendus selon les différents scénarios rencontrés dans les labs :

---

## 1. Analyse du formulaire d’upload

```
------------------------------------------------------
[Analyse] Extraction et analyse du formulaire d'upload
- Champs de formulaire détectés :
    <form action="/my-account/avatar" method="POST" enctype="multipart/form-data">
    <input type="file" name="avatar" accept="image/*">
    <input type="submit" value="Upload">
- Points à vérifier :
    * Nom du champ d'upload (par défaut : avatar)
    * Méthode (POST), enctype (multipart/form-data)
    * Restrictions côté client (accept, type MIME, extensions)
    * Limite de taille (si visible ou message d'erreur)
```
**Comportement attendu** :  
Le script affiche la structure du formulaire, ce qui permet d’identifier le champ, les restrictions de type et la méthode à utiliser pour l’attaque[2][6].

---

## 2. Attaque : upload d’une image légitime

```
------------------------------------------------------
[Attaque] Upload d'une image légitime (test de base)
- Essayez d'accéder à https://<your-lab>.web-security-academy.net/files/avatars/test.jpg
```
**Comportement attendu** :  
- Le script crée et upload une image “innocente” pour vérifier le fonctionnement nominal et le chemin d’accès aux fichiers uploadés[2].

---

## 3. Attaque : upload de fichiers dangereux (webshell, SVG, HTML, polyglotte, etc.)

```
------------------------------------------------------
[Attaque] Upload de fichiers dangereux (webshell, polyglotte, SVG, HTML)
    * Upload de shell.php
    * Upload de shell.php.jpg
    * Upload de shell.jpg.php
    * Upload de shell.php;.jpg
    * Upload de shell.php%00.jpg
    * Upload de shell%2Ephp
    * Upload de shell.svg
    * Upload de shell.html
- Uploads terminés. Passez à la phase de contrôle.
```
**Comportement attendu** :  
- Le script tente d’uploader plusieurs variantes de fichiers malicieux (webshell PHP, SVG XSS, HTML XSS, double extension, null byte, encodage)[2][3][4][6][8].
- Ceci cible tous les bypass classiques : extension, contenu, type MIME, etc.

---

## 4. Attaque : bypass d’extension et encodage

```
------------------------------------------------------
[Attaque] Bypass d'extension (double extension, null byte, encodage)
    * Upload de shell.php
    * Upload de shell.php.jpg
    * Upload de shell.jpg.php
    * Upload de shell.php;.jpg
    * Upload de shell.php%00.jpg
    * Upload de shell%2Ephp
- Testez l'accès à chaque nom de fichier dans /files/avatars/
```
**Comportement attendu** :  
- Le script tente tous les noms de fichiers qui peuvent bypasser une restriction naïve sur l’extension ou le type MIME[2][3][4][8].

---

## 5. Attaque : test de taille

```
------------------------------------------------------
[Attaque] Upload d'un fichier volumineux (test de limite de taille)
- Vérifiez si l'upload est accepté ou rejeté (erreur ou ralentissement possible).
```
**Comportement attendu** :  
- Le script tente d’uploader un gros fichier pour tester la présence d’une limite de taille ou d’un comportement anormal (DoS)[7].

---

## 6. Contrôle : vérification de l’accès, de l’exécution et du téléchargement

```
------------------------------------------------------
[Contrôle] Vérification de l'accessibilité et de l'exécution des fichiers uploadés
    * Test d'accès à https://<your-lab>.web-security-academy.net/files/avatars/test.jpg
      [+] Image accessible.
    * Test d'accès à https://<your-lab>.web-security-academy.net/files/avatars/shell.php
      [+] Fichier exécutable/interprété ! (exécution PHP confirmée)
    * Test d'accès à https://<your-lab>.web-security-academy.net/files/avatars/shell.php.jpg
      [+] Fichier accessible mais code PHP affiché, pas exécuté.
    * Test d'accès à https://<your-lab>.web-security-academy.net/files/avatars/shell.svg
      [+] SVG accessible, testez XSS dans le navigateur.
    * Test d'accès à https://<your-lab>.web-security-academy.net/files/avatars/shell.html
      [+] HTML accessible, testez XSS dans le navigateur.
    * Test d'accès à https://<your-lab>.web-security-academy.net/files/avatars/bigfile.jpg
      [-] Gros fichier rejeté ou tronqué.
- Contrôle terminé. Passez à la remédiation si une faille est détectée.
```
**Comportement attendu** :  
- Le script vérifie automatiquement si les fichiers sont accessibles, exécutés (exécution PHP = vulnérabilité critique[2][4][6]), ou simplement téléchargés.
- Pour SVG/HTML, il recommande de tester l’exploitabilité XSS dans le navigateur.
- Pour les gros fichiers, il signale un éventuel rejet ou une absence de limite (risque DoS).

---

## 7. Remédiation et conseils

```
------------------------------------------------------
[Remédiation & Conseils]
- Filtrez extension et type MIME côté serveur (pas seulement côté client).
- Vérifiez le contenu réel du fichier (magic bytes, signatures).
- Ne stockez jamais de fichier uploadé dans un dossier web-accessible en exécution.
- Renommez le fichier côté serveur (nom aléatoire), ne conservez jamais l'extension d'origine.
- Servez les fichiers uploadés avec Content-Disposition: attachment.
- Pour les labs PortSwigger, validez l'exécution du code, l'accès au secret, ou l'exploit XSS.
- Documentation PortSwigger : https://portswigger.net/web-security/file-upload
```
**Comportement attendu** :  
- Le script rappelle les bonnes pratiques de sécurité et la documentation officielle[1].

---

## 8. Synthèse

```
------------------------------------------------------
[SYNTHÈSE]
1. Analyse du formulaire d'upload et des restrictions côté client.
2. Tentatives d'upload avec images, fichiers dangereux, bypass d'extension, et gros fichiers.
3. Vérification automatique de l'accès, de l'exécution et du comportement serveur.
4. Application des recommandations de sécurité si une faille est trouvée.
------------------------------------------------------
```
