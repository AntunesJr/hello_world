#!/bin/bash

# ============================================================
# Exibição do Rodapé:
# ============================================================

display_footer(){

    local width=$(get_terminal_width)
    local padding=$((width - 2))

    # Borda inferior do conteúdo:
    printf "%${width}s" | tr ' ' '='
    echo ""

    #Barra de progresso visual:
    local pos
    if [[ "$total_pages" -gt 1 ]]; then
       pos=$((current_page * $padding / (total_pages -1)))
    else
       pos=0
    fi

    echo -n "["
    for ((i = 0; i<$padding; i++)); do
        if [[ "$i" -lt "$pos" ]]; then
            echo -n "█"
        else
            echo -n "░"
        fi
    done
    echo "]"

    # Informação da página atual e scroll:
    if [[ "${max_offset:-0}" -gt 0 ]]; then
        local scroll_percent=$(( (scroll_offset * 100) / max_offset ))
        printf "Página ${NEGRITO}%d${RESET} de %d | Rolagem: %d%%${RESET}\n" \
            $((current_page + 1)) $total_pages $scroll_percent
    else
        printf "Página ${NEGRITO}%d${RESET} de %d${RESET}\n" $((current_page + 1)) $total_pages
    fi
    echo ""

    # Instruções de navegação:
    build_footer_message
    echo -ne "$footer_msg_format"
}

# Constrói a mensagem de rodapé:
build_footer_message(){
    local can_go_left=false
    local can_go_right=false
    local can_scroll=false
    local padding

    local left_width=$(($(get_number_characters "$left_msg")))     # Largura para "← Anterior"
    local right_width=$(($(get_number_characters "$right_msg")))   # Largura para "→ Próxima"
    local scroll_width=$(($(get_number_characters "$scroll_msg"))) # Largura para "↑↓ Rolar"

    # Verifica se pode voltar em uma página anterior:
    if [ "${current_page:-0}" -gt 0 ]; then
        can_go_left=true
    fi
 
    # Verifica se pode ir para próxima página:
    if [ "${current_page:-0}" -lt $((total_pages -1)) ]; then
         can_go_right=true
    fi

    # Verifica se o conteúdo é rolável:
    local max_offset=$(get_max_scroll_offset)
    if [ "${max_offset:-0}" -gt 0 ]; then
        can_scroll=true
    fi

    # Forma a mensagem de rodapé:
    footer_msg_format=" "

    if [ "$can_go_left" = true ]; then
        footer_msg_format+="$left_msg"
    else
        printf -v padding '%*s' $left_width ''
        footer_msg_format+="$padding"
    fi

    footer_msg_format+=" "

    if [ "$can_go_right" = true ]; then
        footer_msg_format+="$right_msg"
    else
        printf -v padding '%*s' $right_width ''
        footer_msg_format+="$padding"
    fi

    footer_msg_format+=" "

    if [ "$can_scroll" = true ]; then
        footer_msg_format+="$scroll_msg"
    else
        printf -v padding '%*s' $scroll_width ''
        footer_msg_format+="$padding"
    fi

    footer_msg_format+=" "
    footer_msg_format+="$exit_msg"
}