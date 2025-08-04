#!/bin/bash

# utilities/interactive.sh
# Sistema de configuración interactiva estilo Vite con contexto persistente


# Símbolos Unicode estilo Vite
declare -gr DIAMOND_FILLED='◆'  # Etapa actual
declare -gr DIAMOND_EMPTY='◇'   # Etapa completada
declare -gr RADIO_FILLED='●'    # Opción seleccionada
declare -gr RADIO_EMPTY='○'     # Opción no seleccionada
declare -gr PIPE='│'            # Separador vertical
declare -gr CHECK='✔'
declare -gr CROSS='✖'
# Agregar color inactivo al pipe
declare -gr PIPE_INACTIVE="${GRAY}${PIPE}${RESET}" # Separador vertical inactivo
declare -gr PIPE_ACTIVE="${CYAN}${PIPE}${RESET}"   # Separador vertical activo

# Variables globales para configuración
declare -gA SETUP_CONFIG
declare -ga SETUP_STEPS
declare -g SETUP_TITLE
declare -gi CURRENT_STEP=0

# Función para limpiar pantalla y mostrar contexto completo
# Use: setup_render
setup_render() {
    clear
    echo
    
    # Mostrar título si existe
    if [[ -n "${SETUP_TITLE:-}" ]]; then
        echo -e "${CYAN}${BOLD}${SETUP_TITLE}${RESET}"
        echo
    fi
    
    # Mostrar pasos completados
    for i in "${!SETUP_STEPS[@]}"; do
        local step="${SETUP_STEPS[$i]}"
        local key="${step%%:*}"
        local prompt="${step#*:}"
        
        if [[ $i -lt $CURRENT_STEP ]]; then
            # Paso completado
            echo -e "${GREEN}${DIAMOND_EMPTY}${RESET}  ${prompt}:"
            echo -e "${PIPE_INACTIVE}  ${DIM}$(setup_get_config "$key")${RESET}"
            echo -e "${PIPE_INACTIVE}"
        fi
    done
}

# Función para mostrar título del setup
# Use: setup_title "My Setup Title"
setup_title() {
    SETUP_TITLE="$1"
    setup_render
}

# Función para input de texto con contexto persistente
# Use: setup_input "key" "Prompt message" "Default value" "Validation function"
setup_input() {
    local key="$1"
    local prompt="$2"
    local default="$3"
    local validation_func="$4"
    
    # Agregar paso a la lista
    SETUP_STEPS+=("$key:$prompt")
    
    while true; do
        setup_render
        
        # Mostrar etapa actual
        echo -e "${CYAN}${DIAMOND_FILLED}${RESET}  ${prompt}:"
        echo -ne "${PIPE_ACTIVE}  "
        
        # Mostrar valor por defecto si existe
        if [[ -n "$default" ]]; then
            echo -ne "${GRAY}($default) ${RESET}"
        fi
        
        read -r input
        
        # Usar default si input está vacío
        if [[ -z "$input" && -n "$default" ]]; then
            input="$default"
        fi
        
        # Validar input si se proporciona función de validación
        if [[ -n "$validation_func" ]]; then
            if $validation_func "$input"; then
                setup_set_config "$key" "$input"
                CURRENT_STEP=$((CURRENT_STEP + 1))
                break
            else
                echo -e "${PIPE}  ${RED}${CROSS}${RESET} Invalid input. Please try again."
                echo -e "${PIPE}"
                echo -ne "${PIPE}  Press Enter to continue..."
                read -r
            fi
        else
            setup_set_config "$key" "$input"
            CURRENT_STEP=$((CURRENT_STEP + 1))
            break
        fi
    done
}

# Get secret data input (Do not display characters on screen)
setup_input_secret() {
    local key="$1"
    local prompt="$2"
    local default="$3"
    
    # Agregar paso a la lista
    SETUP_STEPS+=("$key:$prompt")
    
    while true; do
        setup_render
        
        # Mostrar etapa actual
        echo -e "${CYAN}${DIAMOND_FILLED}${RESET}  ${prompt}:"
        echo -ne "${PIPE_ACTIVE}  "
        
        # Mostrar valor por defecto si existe
        if [[ -n "$default" ]]; then
            echo -ne "${GRAY}($default) ${RESET}"
        fi
        
        read -rs input
        
        # Usar default si input está vacío
        if [[ -z "$input" && -n "$default" ]]; then
            input="$default"
        fi
        
        setup_set_config "$key" "$input"
        CURRENT_STEP=$((CURRENT_STEP + 1))
        break
    done
}

# Función para selección múltiple con navegación por flechas
setup_select() {
    local key="$1"
    local prompt="$2"
    local -n options_ref=$3
    local default_index="${4:-0}"
    
    # Agregar paso a la lista
    SETUP_STEPS+=("$key:$prompt")
    
    local selected=$default_index
    
    # Ocultar cursor
    tput civis
    trap "tput cnorm; exit" INT
    
    while true; do
        setup_render
        
        # Mostrar etapa actual
        echo -e "${CYAN}${DIAMOND_FILLED}${RESET}  ${prompt}:"
        
        # Mostrar opciones
        for i in "${!options_ref[@]}"; do
            local marker="${RADIO_EMPTY}"
            local color="${WHITE}"
            
            if [[ $i -eq $selected ]]; then
                marker="${GREEN}${RADIO_FILLED}${RESET}"
                color="${GREEN}"
            fi
            
            echo -e "${PIPE_ACTIVE}  ${marker} ${color}${options_ref[$i]}${RESET}"
        done
        
        # Leer input
        read -rsn1 input_key
        if [[ $input_key == $'\x1b' ]]; then
            read -rsn2 input_key
            case $input_key in
            "[A") # Flecha arriba
                ((selected--))
                ((selected < 0)) && selected=$((${#options_ref[@]} - 1))
                ;;
            "[B") # Flecha abajo
                ((selected++))
                ((selected >= ${#options_ref[@]})) && selected=0
                ;;
            esac
        elif [[ $input_key == "" ]]; then # Enter
            break
        fi
    done
    
    # Restaurar cursor
    tput cnorm
    
    setup_set_config "$key" "${options_ref[$selected]}"
    CURRENT_STEP=$((CURRENT_STEP + 1))
}

# Función para confirmación sí/no
setup_confirm() {
    local key="$1"
    local prompt="$2"
    local default="$3" # "y" o "n"
    
    # Agregar paso a la lista
    SETUP_STEPS+=("$key:$prompt")
    
    local options=("Yes" "No")
    local selected=0
    
    # Determinar selección por defecto
    if [[ "$default" == "n" ]]; then
        selected=1
    fi
    
    # Ocultar cursor
    tput civis
    trap "tput cnorm; exit" INT
    
    while true; do
        setup_render
        
        # Mostrar etapa actual
        echo -e "${CYAN}${DIAMOND_FILLED}${RESET}  ${prompt}:"
        
        # Mostrar opciones Yes/No
        for i in "${!options[@]}"; do
            local marker="${RADIO_EMPTY}"
            local color="${WHITE}"
            
            if [[ $i -eq $selected ]]; then
                marker="${GREEN}${RADIO_FILLED}${RESET}"
                color="${GREEN}"
            fi
            
            echo -e "${PIPE_ACTIVE}  ${marker} ${color}${options[$i]}${RESET}"
        done
        
        # Leer input
        read -rsn1 input_key
        if [[ $input_key == $'\x1b' ]]; then
            read -rsn2 input_key
            case $input_key in
            "[A"|"[B") # Flechas arriba/abajo
                selected=$((1 - selected)) # Toggle entre 0 y 1
                ;;
            esac
        elif [[ $input_key == "" ]]; then # Enter
            break
        elif [[ "${input_key,,}" == "y" ]]; then
            selected=0
            break
        elif [[ "${input_key,,}" == "n" ]]; then
            selected=1
            break
        fi
    done
    
    # Restaurar cursor
    tput cnorm
    
    if [[ $selected -eq 0 ]]; then
        setup_set_config "$key" "yes"
    else
        setup_set_config "$key" "no"
    fi
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
}

# Función para mostrar resumen final
# Use: setup_summary
setup_summary() {
    setup_render

    echo -e "${YELLOW}${DIAMOND_FILLED}${RESET}  ${BOLD}Configuration Summary:${RESET}"
    echo -e "${PIPE_ACTIVE}"
    
    for step in "${SETUP_STEPS[@]}"; do
        local key="${step%%:*}"
        local prompt="${step#*:}"
        if [[ "summary" == "$key" ]]; then
            continue
        fi

        echo -e "${PIPE_ACTIVE}  ${CYAN}${prompt}:${RESET} $(setup_get_config "$key")"
    done
    echo -e "${PIPE_ACTIVE}" 
    setup_pause
}

# Función para validar nombre de directorio
# Use: validate_new_directory "my_directory"
# Devuelve 0 si es válido, 1 si no lo es.
validate_new_directory() {
    local dir_name="$1"
    if [[ -d "$dir_name" ]]; then
        return 1
    fi
    if [[ ! "$dir_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 1
    fi
    return 0
}

# Función para validar nombre del proyecto
# Use: validate_project_name "my_project"
# Devuelve 0 si es válido, 1 si no lo es.
validate_project_name() {
    local name="$1"
    if [[ -z "$name" ]]; then
        return 1
    fi
    if [[ ${#name} -lt 2 ]]; then
        return 1
    fi
    return 0
}

# Función para validar email
# Use: validate_email "example@mail.com"
# Devuelve 0 si es válido, 1 si no lo es.
validate_email() {
    local email="$1"
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 1
    fi
    return 0
}

# Función para validar URL
# Use: validate_url "http://example.com"
# Devuelve 0 si es válida, 1 si no lo es.
validate_url() {
    local url="$1"
    if [[ ! "$url" =~ ^https?:// ]]; then
        return 1
    fi
    return 0
}

# Función para limpiar configuración
# Use: setup_clear
setup_clear() {
    unset SETUP_CONFIG SETUP_STEPS SETUP_TITLE
    declare -gA SETUP_CONFIG
    declare -ga SETUP_STEPS
    declare -gi CURRENT_STEP=0
}

# Función auxiliar para asignar valores al config
# Use: setup_set_config "key" "value"
setup_set_config() {
    local key="$1"
    local value="$2"
    SETUP_CONFIG["$key"]="$value"
}

# Función auxiliar para obtener valores del config
# Use: setup_get_config "key"
setup_get_config() {
    local key="$1"
    echo "${SETUP_CONFIG[$key]:-}"
}

# Alias de setup_get_config, para compatibilidad
setup_get() {
    setup_get_config "$@"
}

# Función para verificar si todas las configuraciones están completas
# Use: setup_is_complete
# Devuelve 0 si hay configuraciones, 1 si no.
setup_is_complete() {
    [[ ${#SETUP_CONFIG[@]} -gt 0 ]]
}

# Función para pausar la ejecución y esperar input del usuario
# Use: setup_pause
setup_pause() {
    echo -e "${PIPE_ACTIVE}"
    echo -ne "${PIPE_ACTIVE}  Press Enter to continue..."
    read -r
}
