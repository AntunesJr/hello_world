#!/bin/bash

# ============================================================
# Display Funções para exibição de páginas com rolagem.
# ============================================================

# Quantidade de linhas o cabeçalho e rodapé ocupam:
get_header_footer_lines(){
    echo 10
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
    local width=$(get_terminal_width)
    local max_chars=$((width - 2))

    CONTENT_LINES=()

    # Preserva linhas vazias e espaços no inicio das linhas:
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Verifica se a linha é vazia ou menor que o máximo de caracteches por linha:
        if [[ -z "$line" ]] || [[ ${#line} -le $max_chars ]]; then
            CONTENT_LINES+=("$line")
        else # Caso seja maior que o número máximo de caracteres faz o tratamento:
            local remaining="$line"
            while [[ ${#remaining} -gt $max_chars ]]; do
                local chunk="${remaining:0:$max_chars}"
                local last_space=-1
                local i
                #procura o último espaço:
                for ((i=${#chunk}-1; i>=0; i--)); do
                    if [[ "${chunk:$i:1}" == " " ]]; then
                        last_space=$i
                        break
                    fi
                done

                # Tenta quebrar linha no último espaço antes do limite:
                if [[ "$last_space" -gt 0 ]]; then
                    CONTENT_LINES+=("${remaining:0:$last_space}")
                    remaining="${remaining:$((last_space + 1))}"
                # Força quebra de linha no limite:
                else
                    CONTENT_LINES+=("$chunk")
                    remaining="${remaining:${#chunk}}"
                fi
            done
            [[ -n "$remaining" ]] && CONTENT_LINES+=("$remaining")
        fi
    done <<< "$content"
}