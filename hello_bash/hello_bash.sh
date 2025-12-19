#!/bin/bash

export LC_ALL=pt_BR.UTF-8

# CONTROLES:
# ← → : Navegar entre páginas.
# ↑ ↓ : Rolar conteúdo da página atual.
# Page Up/Down : Rolar rápidamente.
# Home/End: Ir para início/fim do contúdo.
# Q : Sair.

# Códigos ANSI:
RESET='\033[0m'
NEGRITO='\033[1m'

# Variáveis Globais:
declare -a PAGE_TITLES=()
declare -a PAGE_CONTENTS=()
declare -a CONTENT_LINES=()

current_page=0
total_pages=0
scroll_offset=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================
# Importar funções:
# ============================================================
source "${SCRIPT_DIR}/fun/screen/display_page.sh"
source "${SCRIPT_DIR}/fun/load_pages_json.sh"
source "${SCRIPT_DIR}/fun/terminal_utils.sh"
source "${SCRIPT_DIR}/fun/scroll_page.sh"
source "${SCRIPT_DIR}/fun/read_key.sh"

# ============================================================
# Mensagens de Navegação:
# ============================================================
exit_msg="${NEGRITO}Q${RESET} para sair"
left_msg="${NEGRITO}←${RESET} Anterior"
right_msg="${NEGRITO}→${RESET} Próxima"
scroll_msg="${NEGRITO}↑↓${RESET} Rolar"

# ============================================================
# Função Principal:
# ============================================================

main(){
    load_pages_json
    save_screen
    trap cleanup EXIT
    enable_raw_mode

    while true; do
        display_page
        local key=$(read_key)
        
        case "$key" in
            "RIGHT")
                if [ $current_page -lt $((total_pages - 1)) ]; then
                    ((current_page++))
                    reset_scroll
                fi
                ;;
            "LEFT")
                if [ $current_page -gt 0 ]; then
                    ((current_page--))
                    reset_scroll
                fi
                ;;
            "UP")
                scroll_up 1
                ;;
            "DOWN")
                scroll_down 1
                ;;
            "PAGEUP")
                local half_page=$(($(get_visible_lines_count) / 2))
                scroll_up $half_page
                ;;
            "PAGEDOWN")
                local half_page=$(($(get_visible_lines_count) / 2))
                scroll_down $half_page
                ;;
            "HOME")
                scroll_to_top
                ;;
            "END")
                scroll_to_bottom
                ;;
            [qQ])
                break
                ;;
        esac
    done
}

main