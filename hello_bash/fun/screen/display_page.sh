#!/bin/bash

# ============================================================
# Importar funções:
# ============================================================
source "${SCRIPT_DIR}/fun/screen/display_scroll.sh"
source "${SCRIPT_DIR}/fun/screen/display_footer.sh"

# ============================================================
# Função De Exibição:
# ============================================================

display_header(){

    # Cabeçalho:
    local title="${PAGE_TITLES[$current_page]}"
    local width=$(get_terminal_width)
    local head="=== Hello GNU Bash ==="
    local number_characters=$(($(get_number_characters "$head")))

    local padding=$((width - 2))
    local head_padding=$((padding - number_characters))
    local head_padding_left=$((head_padding/2))
    local head_padding_right=$(((head_padding/2)+(head_padding%2)))

    echo -ne "${NEGRITO}"

    # Borda superior do cabeçalho:
    printf "╔%${padding}s╗" | tr ' ' '='
    echo ""

    # Título do programa:
    printf "║%${head_padding_left}s$head%${head_padding_right}s║"
    echo ""

    # Borda inferior do cabeçalho:
    printf "╚%${padding}s╝" | tr ' ' '='
    echo -ne "${RESET}"
    echo ""

    # Título da pągina:
    local number_characters=${#title}
    local padding=$((width - number_characters))
    
    printf "%${padding}s" " "

    echo -e "${NEGRITO}$title${RESET}"
    echo ""
}

display_content(){
    split_content_into_lines "${PAGE_CONTENTS[$current_page]}"

    local total_lines=$(get_total_content_lines)
    local visible_lines=$(get_visible_lines_count)
    local max_offset=$(get_max_scroll_offset)

    # Garante que o scroll_offset máximo não estoure:
    if [[ "${scroll_offset:-0}" -gt "${max_offset:-0}" ]]; then
        scroll_offset=$max_offset
    fi

    # Seta o total de linhas:
    local end_line=$((scroll_offset + visible_lines))
    if [ $end_line -gt $total_lines ]; then
        end_line=$total_lines
    fi

    # Exibe linhas visíveis:
    local lines_shown=0
    for ((i = scroll_offset; i<end_line; i++)); do
        echo -e "${CONTENT_LINES[$i]}"
        ((lines_shown++))
    done

    # Quantidade linhas a ser preenchidas:
    local remaining=$((visible_lines - lines_shown))

    if [[ "$remaining" -lt 0 ]]; then
        remaining=0
    fi

    # Preenche linhas vazias restantes:
    for ((i=0; i<remaining; i++)); do
        echo ""
    done
}

display_page(){
    clear_safe
    display_header
    display_content
    display_footer
}
