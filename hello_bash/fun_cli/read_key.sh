#!/bin/bash

# ============================================================
# Captura de teclas:
# ============================================================

read_key(){
    local key
    read -r -s -N1 key

    if [[ "$key" == $'\x1b' ]]; then
        read -r -s -N2 key
        case "$key" in
            '[A') echo "UP" ;;
            '[B') echo "DOWN" ;;
            '[C') echo "RIGHT" ;;
            '[D') echo "LEFT" ;;
            '[5')
                read -r -s -N1
                echo "PAGEUP"
                ;;
            '[6')
                read -r -s -N1
                echo "PAGEDOWN"
                ;;
            '[H') echo "HOME" ;;
            '[F') echo "END" ;;
            *)    echo "ESC" ;;
        esac
    else
        echo "$key"
    fi
}