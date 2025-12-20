#!/bin/bash

# Converte arquivos .txt em um único arquivo JSON:
txt_to_json() {
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local input_dir="${1:-$SCRIPT_DIR/pages}"
    local output_file="${2:-$SCRIPT_DIR/json/pages.json}"

    # Verifica se o diretório existe
    if [ ! -d "$input_dir" ]; then
        echo "Erro: Diretório '$input_dir' não encontrado!"
        return 1
    fi

    echo "{" > "$output_file"
    echo '  "pages": [' >> "$output_file"
    
    local first_item=true
    
    while IFS= read -r file; do
        
        # Extrai apenas o nome base do arquivo:
        local filename=$(basename "$file")
        
        # Remove a extensão .txt do nome base do arquivo:
        local name_without_ext="${filename%.txt}"
        
        # Extrai o titulo:
        local title="${name_without_ext#*-}"

        if [ "$title" = "$name_without_ext" ]; then
            title="$name_without_ext"
        fi
        
        # Garante a primeira letra em maiúsculo:
        title="$(echo "${title:0:1}" | tr '[:lower:]' '[:upper:]')${title:1}"
        
        # Extrai o conteúdo do arquivo:
        local content=""
        while IFS= read -r line || [ -n "$line" ]; do

            # Adapta caracteres especiais para JSON:
            line=$(printf '%s' "$line" | sed 's/\\/\\\\/g; s/"/\\"/g')
            
            # Adciona \\n para quebra de linhas:
            if [ -n "$content" ]; then
                content="${content}\\n${line}"
            else
                content="${line}"
            fi
        done < "$file"
        
        # Adiciona vírgula antes do item, exceto no primeiro
        if [ "$first_item" = true ]; then
            first_item=false
        else
            echo "," >> "$output_file"
        fi
        
        # Escreve a página no objeto json:
        echo '    {' >> "$output_file"
        echo "      \"title\": \"$title\"," >> "$output_file"
        echo "      \"content\": \"$content\"" >> "$output_file"
        echo -n '    }' >> "$output_file"
        
    done < <(find "$input_dir" -name "*.txt" -type f | sort)
    
    # Fecha o array e o objeto JSON principal:
    echo "" >> "$output_file"
    echo '  ]' >> "$output_file"
    echo '}' >> "$output_file"
    
    echo "✓ JSON criado com sucesso em: $output_file"

    local page_count=$(find "$input_dir" -name "*.txt" -type f | wc -l)
    echo "✓ Total de páginas processadas: $page_count"
}

txt_to_json
