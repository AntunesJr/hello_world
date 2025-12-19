#!/bin/bash

# ============================================================
# Display Funções para exibição de páginas com rolagem.
# ============================================================

# Quantidade de linhas o cabeçalho e rodapé ocupam:
get_header_footer_lines(){
    echo 12
}

# Conta o total de linhas do conteúdo atual:
get_total_content_lines(){
    echo "${#CONTENT_LINES[@]}"
}

# Calcula quantas linhas de conteúdo cabem na área visível:
get_visible_lines_count(){
    local terminal_height=$(get_terminal_height)
    local fixed_lines=$(get_header_footer_lines)
    local available=$((terminal_height - fixed_lines))

    # Garante sempre ao menos uma úníca linha visível:
    if [[ "$available" -lt 1 ]]; then
        available=1
    fi

    echo "$available"
}

# Calcula o offset máximo de scroll:
get_max_scroll_offset(){
    local total_lines=$(get_total_content_lines)
    local visible_lines=$(get_visible_lines_count)
    local max_offset=$((total_lines - visible_lines))

    # Garante o offset mínimi em 0.
    if [[ "$max_offset" -lt 0 ]]; then
        max_offset=0
    fi

    echo "$max_offset"
}

# Divide o conteúdo em uma array de linhas, possibilanto rolagem:
split_content_into_lines(){
    local content="$1"

    CONTENT_LINES=()

    # Preserva linhas vazias e espaços no inicio das linhas:
    while IFS= read -r line || [[ -n "$line" ]]; do
        CONTENT_LINES+=("$line")
    done <<< "$content"
}