#!/bin/bash

# ============================================================
# Carregamento de páginas:
# ============================================================

# Função que carrega pąginas:
load_pages_json(){

    local json_file="${SCRIPT_DIR}/pages/pages.json"
    
    if ! command -v jq &> /dev/null; then
        echo "Erro: 'jq' não está instalado."
        echo "Instale no Debian com: sudo apt install jq"
        echo "      ou no MacOs com: brew install jq"
        exit 1
    fi

    if [ ! -f "$json_file" ]; then
        echo "Erro: Arquivo '$json_file' não encontrado."
        echo "${SCRIPT_DIR}/pages/pages.json"
        exit  1
    fi

    local page_count
    page_count=$(jq '.pages | length' "$json_file")

    for ((i = 0; i < page_count; i++ )); do
        local content=$(jq -r ".pages[$i].content" "$json_file")

        PAGE_TITLES+=("$(jq -r ".pages[$i].title" "$json_file")")
        PAGE_CONTENTS+=("$(jq -r ".pages[$i].content" "$json_file")")
    done

    total_pages=${#PAGE_CONTENTS[@]}
}