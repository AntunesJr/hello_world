#!/bin/bash

# Calcula quantos caracteres tem uma string:
get_number_characters(){
    local str="$1"
    
    local interpreted=$(printf '%b' "$str")
    local clean_str=$(printf '%s' "$interpreted" | sed 's/\x1b\[[0-9;]*m//g')

    LC_ALL=C.UTF-8 bash -c 'printf "%s" "$1" | wc -m' _ "$clean_str" | tr -d ' '
}

# ============================================================
# Funções utilitárias para CLI:
# ============================================================

# Funções de entrada raw, captura de teclas:
enable_raw_mode(){
    stty -echo -icanon min 1 time 0
}

# Função que restaura o terminal:
disable_raw_mode(){
    stty echo icanon
}

# Função para salvar o estado do terminal:
save_screen(){
    if command -v tput &> /dev/null; then
        tput smcup
    else
        printf '\033[?1049h'
    fi
}

# Função que restaura o estado do terminal:
restore_screen(){
    if command -v tput &> /dev/null; then
        tput rmcup
    else
        printf '\033[1049l'
    fi
}

# FUnção para limpar a tela:
clear_safe(){
    clear
}

# Função de limpeza ao sair do script:
cleanup(){
    disable_raw_mode
    restore_screen
}

# ============================================================
# Funções de dimensões do terminal:
# ============================================================

# Obtém a altura do terminal:
get_terminal_height(){
    local height

    # Tenta usar o tput:
    if command -v tput &> /dev/null; then
        height=$(tput lines)
    elif [ -n "$LINES" ]; then
        height=$LINES
    else
        height=$(stty size 2>/dev/null | cut -d' ' -f1)
    fi

    echo "${height:-24}"
}

# Obtem a largura do terminal:
get_terminal_width() {
    local width default_width=80
    
    # 1. tput (método mais confiável)
    if command -v tput >/dev/null 2>&1; then
        width=$(tput cols 2>/dev/null)
        if [[ -n "$width" && "$width" =~ ^[0-9]+$ && "$width" -gt 0 ]]; then
            echo "$width"
            return 0
        fi
    fi
    
    # 2. Variável COLUMNS
    if [[ -n "$COLUMNS" && "$COLUMNS" =~ ^[0-9]+$ && "$COLUMNS" -gt 0 ]]; then
        echo "$COLUMNS"
        return 0
    fi
    
    # 3. stty
    if command -v stty >/dev/null 2>&1; then
        width=$(stty size 2>/dev/null | awk '{print $2}')
        if [[ -n "$width" && "$width" =~ ^[0-9]+$ && "$width" -gt 0 ]]; then
            echo "$width"
            return 0
        fi
    fi
    
    # 4. Valor padrão
    echo "$default_width"
    return 1
}