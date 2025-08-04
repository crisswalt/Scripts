#!/bin/bash

# Filename: utilities/requirements.sh

# This script provides utility functions for managing requirements and logging.

import "utilities/translator.sh"

# Function check_version
# This function checks if a command meets the minimum version requirement.
# Use: check_version "command" "minimum_version"
# Returns 0 if the command meets the requirement, 1 otherwise.
check_version() {
    local cmd="$1"
    local min_version="$2"
    local current_version=""
    
    # Try different common methods to get version
    current_version=$($cmd --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    
    if [[ -z "$current_version" ]]; then
        current_version=$($cmd -V 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    fi
    
    if [[ -z "$current_version" ]]; then
        current_version=$($cmd -v 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    fi
    
    if [[ -z "$current_version" ]]; then
        current_version=$($cmd version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    fi
    
    if [[ -z "$current_version" ]]; then
        current_version=$($cmd -version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    fi
    
    # If we couldn't get version
    if [[ -z "$current_version" ]]; then
        log_warning "$(trans "The \$cmd version could not be determined.")"
        return 0  # Asumir que está bien
    fi
    
    # Comparar versiones (función auxiliar)
    if version_compare "$current_version" "$min_version"; then
        return 0
    else
        log_error "$(trans "The \$cmd version is too old. Minimum required is \$min_version, but found \$current_version.")"
        return 1
    fi
}

# Function version_compare
# This function compares two version strings.
# It returns 0 if version1 is greater than or equal to version2, 1 otherwise.
# Use: version_compare "version1" "version2"
# Returns 0 if version1 >= version2, 1 if version1 < version2
# Example: version_compare "1.2.3" "1.2.0"
version_compare() {
    local version1="$1"
    local version2="$2"
    
    # Convertir a arrays para comparación
    IFS='.' read -ra V1 <<< "$version1"
    IFS='.' read -ra V2 <<< "$version2"
    
    # Comparar cada parte
    for ((i=0; i<${#V2[@]}; i++)); do
        if [[ -z "${V1[i]}" ]]; then
            V1[i]=0
        fi
        if [[ "${V1[i]}" -lt "${V2[i]}" ]]; then
            return 1
        elif [[ "${V1[i]}" -gt "${V2[i]}" ]]; then
            return 0
        fi
    done
    
    return 0
}

# Function check_requirements
# This function checks if the required commands are available and meet their version requirements.
# Use: check_requirements "command1" "command2:version" ...
# Returns 0 if all requirements are met, 1 if any requirement is missing or does not meet the version.
# Example: check_requirements "node:18.0.0"
check_requirements() {
    local missing=()
    local requirement
    
    for requirement in "$@"; do
        case "$requirement" in
            *:*)
                # Validation for command with version
                # Format: command:version
                # Example: node:18.0.0
                local cmd="${requirement%:*}"
                local version="${requirement#*:}"
                
                if ! command -v "$cmd" >/dev/null 2>&1; then
                    missing+=("$cmd ($(trans "command not found"))")
                elif ! check_version "$cmd" "$version"; then
                    missing+=("$cmd ($(trans "version") >= $version)")
                fi
                ;;
            *)
                # Validation for command without version
                # Example: node
                if ! command -v "$requirement" >/dev/null 2>&1; then
                    missing+=("$requirement")
                fi
                ;;
        esac
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "$(trasn "Missing requirements:")"
        for req in "${missing[@]}"; do
            log_error "  - $req"
        done
        exit 1
    fi
}