#!/bin/bash

# ============================================================
# Funções de controle:
# ============================================================

# Resete do scroll:
reset_scroll(){
    scroll_offset=0
}

# Movimento do scroll para cima:
scroll_up(){
    local amount=${1:-1}

    scroll_offset=$((scroll_offset - amount))
    if [ $scroll_offset -lt 0 ]; then
        scroll_offset=0
    fi
}

# Movimento do scroll para baixo:
scroll_down(){
    local amount=${1:-1}
    local max_offset=$(get_max_scroll_offset)

    scroll_offset=$((scroll_offset + amount))
    if [ $scroll_offset -gt $max_offset ]; then
        scroll_offset=$max_offset
    fi
}

# Movimento do scroll para o início:
scroll_to_top(){
    scroll_offset=0
}

# Movimento do scroll para o final:
scroll_to_bottom(){
    scroll_offset=$(get_max_scroll_offset)
}