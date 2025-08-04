#!/bin/bash

# Filename: Scripts/test-interactive.sh
# Test exclusivo para utilities/interactive.sh

# Load environment variables if .env file exists
[ -f ".env" ] && source .env

# Import bootstrap script from the specified BASEURL
BASEURL=${BASEURL:-"https://raw.githubusercontent.com/crisswalt/Scripts/main"}
if ! source <(curl -fsSL "${BASEURL}/bootstrap.sh"); then
    echo -e "\e[0;31mError: Failed to import scripts from ${BASEURL}.\e[0m" >&2
    exit 1
fi

# Import required utilities
import "utilities/translator.sh"
import "utilities/interactive.sh"

# Función de test principal
test_interactive_system() {
    echo "=== Testing Interactive Setup System ==="
    echo "Current LANG: $LANG"
    echo
    
    # Limpiar configuración previa
    setup_clear
    
    # Título del setup
    setup_title "$(trans "Interactive System Test")"
    
    # Test 1: Input básico
    setup_input "project_name" \
                "$(trans "Enter project name")" \
                "test-project" \
                "validate_project_name"
    
    # Test 2: Input con validación personalizada
    setup_input "user_age" \
                "$(trans "Enter your age")" \
                "25" \
                "validate_age"
    
    # Test 3: Selección múltiple
    local frameworks=("React" "Vue" "Angular" "Svelte" "Vanilla JS")
    setup_select "framework" \
                 "$(trans "Select a framework")" \
                 frameworks \
                 0  # Default a React
    
    # Test 4: Selección de colores
    local colors=("Red" "Green" "Blue" "Yellow" "Purple")
    setup_select "favorite_color" \
                 "$(trans "Choose your favorite color")" \
                 colors \
                 2  # Default a Blue
    
    # Test 5: Confirmación simple
    setup_confirm "enable_typescript" \
                  "$(trans "Enable TypeScript support")" \
                  "y"
    
    # Test 6: Confirmación con default No
    setup_confirm "enable_testing" \
                  "$(trans "Include testing framework")" \
                  "n"
    
    # Test 7: Input condicional (basado en respuesta anterior)
    if [[ "$(setup_get "enable_testing")" == "yes" ]]; then
        local test_frameworks=("Jest" "Vitest" "Cypress" "Playwright")
        setup_select "test_framework" \
                     "$(trans "Select testing framework")" \
                     test_frameworks \
                     0
    fi
    
    # Test 8: Input con validación de email
    setup_input "email" \
                "$(trans "Enter your email")" \
                "test@example.com" \
                "validate_email"
    
    # Test 9: Input opcional (sin validación)
    setup_input "description" \
                "$(trans "Project description (optional)")" \
                "A test project for interactive setup"
    
    # Mostrar resumen final
    setup_summary
    
    # Confirmación final
    setup_confirm "save_config" \
                  "$(trans "Save this configuration")" \
                  "y"
    
    # Mostrar resultados
    show_test_results
}

# Función de validación personalizada para edad
validate_age() {
    local age="$1"
    if [[ ! "$age" =~ ^[0-9]+$ ]]; then
        echo -e "   ${RED}Age must be a number.${RESET}"
        return 1
    fi
    if (( age < 1 || age > 120 )); then
        echo -e "   ${RED}Age must be between 1 and 120.${RESET}"
        return 1
    fi
    return 0
}

# Función para mostrar resultados del test
show_test_results() {
    clear
    echo
    echo -e "${GREEN}${BOLD}=== TEST COMPLETED SUCCESSFULLY ===${RESET}"
    echo
    echo -e "${CYAN}${BOLD}Final Configuration:${RESET}"
    echo
    
    # Mostrar todas las configuraciones
    echo -e "${YELLOW}Basic Information:${RESET}"
    echo -e "  Project Name: ${BOLD}$(setup_get "project_name")${RESET}"
    echo -e "  User Age: ${BOLD}$(setup_get "user_age")${RESET}"
    echo -e "  Email: ${BOLD}$(setup_get "email")${RESET}"
    echo -e "  Description: ${BOLD}$(setup_get "description")${RESET}"
    echo
    
    echo -e "${YELLOW}Technical Choices:${RESET}"
    echo -e "  Framework: ${BOLD}$(setup_get "framework")${RESET}"
    echo -e "  Favorite Color: ${BOLD}$(setup_get "favorite_color")${RESET}"
    echo -e "  TypeScript: ${BOLD}$(setup_get "enable_typescript")${RESET}"
    echo -e "  Testing: ${BOLD}$(setup_get "enable_testing")${RESET}"
    
    if [[ "$(setup_get "enable_testing")" == "yes" ]]; then
        echo -e "  Test Framework: ${BOLD}$(setup_get "test_framework")${RESET}"
    fi
    echo
    
    echo -e "${YELLOW}Actions:${RESET}"
    echo -e "  Save Config: ${BOLD}$(setup_get "save_config")${RESET}"
    echo
    
    # Test de funciones auxiliares
    echo -e "${CYAN}${BOLD}Testing utility functions:${RESET}"
    echo -e "  setup_is_complete(): $(setup_is_complete && echo "✔ true" || echo "✖ false")"
    echo -e "  Number of configs: ${#SETUP_CONFIG[@]}"
    echo -e "  Number of steps: ${#SETUP_STEPS[@]}"
    echo
    
    # Mostrar mensaje final
    if [[ "$(setup_get "save_config")" == "yes" ]]; then
        echo -e "${GREEN}${CHECK}${RESET} Configuration would be saved!"
        echo -e "${GRAY}(In a real scenario, this would create config files)${RESET}"
    else
        echo -e "${YELLOW}Configuration discarded.${RESET}"
    fi
    echo
    
    echo -e "${CYAN}${BOLD}Interactive System Test Complete!${RESET}"
    echo -e "${GRAY}All functions tested successfully.${RESET}"
    echo
}

# Ejecutar test
test_interactive_system