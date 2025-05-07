Voici un **exemple d’exploitation du script Bash** pour le challenge **Unprotected admin functionality** de PortSwigger, en suivant toutes les étapes du lab :

---

## 1. Lancement du script

Supposons que l’URL du lab soit :  
`https://acb11f1e1f3e4b2ac0b1c2d3e4f5g6h7.web-security-academy.net`

Dans votre terminal, lancez :

```bash
./unprotected_admin.sh https://acb11f1e1f3e4b2ac0b1c2d3e4f5g6h7.web-security-academy.net
```

---

## 2. Ce que fait le script

- **Analyse** :  
  Il télécharge `/robots.txt` pour trouver le chemin de l’admin panel (par exemple `/administrator-panel`).

- **Accès à l’admin** :  
  Il visite la page admin et cherche le lien de suppression de l’utilisateur `carlos` (souvent une URL du type `/administrator-panel/delete?username=carlos`).

- **Suppression** :  
  Il envoie une requête GET sur ce lien pour supprimer l’utilisateur `carlos`.

---

## 3. Exemple de sortie du script

```text
[*] Recherche du chemin admin dans robots.txt...
[+] Chemin admin trouvé : /administrator-panel
[*] Recherche du lien de suppression pour carlos...
[+] Lien de suppression trouvé : /administrator-panel/delete?username=carlos
[*] Suppression de l'utilisateur carlos...
[+] Requête envoyée. Vérifiez l'interface du lab pour la validation.
```

---

## 4. Contrôle

- Rendez-vous sur la page du lab dans votre navigateur.
- Vous devriez voir le message :  
  **"Congratulations, you solved the lab!"**

---

## 5. Référence

Ce processus correspond exactement à la démarche décrite dans les writeups et vidéos d’exploitation du lab :  
- Découverte du chemin admin via `robots.txt`
- Accès direct à l’admin panel (pas de contrôle d’accès)
- Suppression de l’utilisateur `carlos` via l’interface ou le lien direct[1][5][8].

