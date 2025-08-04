#!/bin/bash

declare -A __translations
__translation_loaded=0
__current_lang=""

# Function trans - Translate text based on the current language setting.
# It loads translations from .po files located in the translations directory.
# If the text is empty or the language is English, it returns the original text.
# If the language changes, it reloads the translations.
# Use: trans "text to translate"
# Returns the translated text or the original text if no translation is found.
# It supports both general translations and script-specific translations.
# The script-specific translations take precedence over the general ones.
trans() {
    local script_file="$0"
    local text="$1"
    local lang_code="${LANG:0:2}"

    # Si no hay texto o es inglés, devolver el texto original
    [[ -z "$text" || "$lang_code" == "en" ]] && {
        echo "$text"
        return
    }

    # Detectar cambio de idioma y recargar si es necesario
    if [[ "$__current_lang" != "$lang_code" ]]; then
        __translation_loaded=0
        __current_lang="$lang_code"
        # Limpiar traducciones anteriores
        unset __translations
        declare -gA __translations
    fi

    # Cargar traducciones una sola vez
    if [[ $__translation_loaded -eq 0 ]]; then
        local po_content=""
        
        # Cargar archivo de idioma general
        local general_po
        general_po=$(require "translations/${lang_code}.po" 2>/dev/null) || general_po=""
        
        # Cargar archivo específico del script por idioma
        local script_name=$(basename "$script_file" .sh)
        local script_specific_po_path="${SCRIPT_SPECIFIC_PO_PATH:-translations/${script_name}}"
        local script_specific_po
        script_specific_po=$(require "${script_specific_po_path}/${lang_code}.po" 2>/dev/null) || script_specific_po=""
        
        # Combinar contenidos (específico tiene prioridad sobre general)
        po_content="$general_po"
        [[ -n "$script_specific_po" ]] && po_content+=$'\n'"$script_specific_po"

        __translation_loaded=1

        # Parsear contenido PO
        local msgid=""
        local msgstr=""
        local in_msgstr=0
        
        while IFS= read -r line; do
            # Limpiar espacios en blanco al inicio y final
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            # Ignorar comentarios y líneas vacías
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            
            if [[ "$line" =~ ^msgid[[:space:]]+\"(.*)\"$ ]]; then
                # Guardar traducción anterior si existe
                if [[ -n "$msgid" && -n "$msgstr" ]]; then
                    __translations["$msgid"]="$msgstr"
                fi
                
                msgid="${BASH_REMATCH[1]}"
                msgstr=""
                in_msgstr=0
                
            elif [[ "$line" =~ ^msgstr[[:space:]]+\"(.*)\"$ ]]; then
                msgstr="${BASH_REMATCH[1]}"
                in_msgstr=1
                
            elif [[ "$line" =~ ^\"(.*)\"$ ]]; then
                # Línea de continuación
                if [[ $in_msgstr -eq 1 ]]; then
                    msgstr+="${BASH_REMATCH[1]}"
                else
                    msgid+="${BASH_REMATCH[1]}"
                fi
            fi
        done <<< "$po_content"
        
        # Guardar última traducción
        if [[ -n "$msgid" && -n "$msgstr" ]]; then
            __translations["$msgid"]="$msgstr"
        fi
    fi

    # Devolver traducción o texto original
    eval "result=\"${__translations[$text]:-$text}\""
    echo "$result" 
}

# Función auxiliar para debugging (opcional)
trans_debug() {
    echo "Traducciones cargadas:" >&2
    for key in "${!__translations[@]}"; do
        echo "  '$key' -> '${__translations[$key]}'" >&2
    done
}

# Función para limpiar cache de traducciones (opcional)
trans_reload() {
    unset __translations
    declare -gA __translations
    __translation_loaded=0
    __current_lang=""
}