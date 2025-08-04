#!/bin/bash

#/**
# * Filename: Scripts/test-requirementes.sh
# * Test script for the requirements functionality of the Scripts repository
# * This script tests the import and error handling of the requirements script.
# */

set -e

# Load environment variables if .env file exists
[ -f ".env" ] && source .env

# Import bootstrap script from the specified BASEURL
BASEURL=${BASEURL:-"https://raw.githubusercontent.com/crisswalt/Scripts/main"}
if ! source <(curl -fsSL "${BASEURL}/bootstrap.sh"); then
    echo -e "\e[0;31mError: Failed to import scripts from ${BASEURL}.\e[0m" >&2
    exit 1
fi

import "utilities/requirements.sh"

spec_check_version() {
    local cmd="$1"
    local min_version="$2"
    
    if check_version "$cmd" "$min_version" 2>/dev/null; then
        log_success "Spec 'check_version' for '$cmd' is working as expected."
    else
        log_error "Spec 'check_version' for '$cmd' did not meet the minimum version requirement."
    fi
}   

spec_version_compare() {
    local version1="$1"
    local version2="$2"
    
    if version_compare "$version1" "$version2" 2>/dev/null; then
        log_success "Spec 'version_compare' for '$version1' and '$version2' is working as expected."
    else
        log_error "Spec 'version_compare' for '$version1' and '$version2' did not compare correctly."
    fi
}

spec_check_requirements() {
    
    if check_requirements $@ 2>/dev/null; then
        log_success "Spec 'check_requirements' for ($@) is working as expected."
    else
        log_error "Spec 'check_requirements' for '$cmd' did not meet the minimum version requirement."
    fi
}


spec_failed_check_version() {
    local cmd="$1"
    local min_version="$2"
    
    if ! check_version "$cmd" "$min_version" 2>/dev/null; then
        log_success "Spec 'failed_check_version' for '$cmd' is working as expected."
    else
        log_error "Spec 'failed_check_version' for '$cmd' did not fail as expected."
    fi
} 

spec_failed_requirements() {
    local cmd="$1"
    local min_version="$2"
    
    if ! check_version "$cmd" "$min_version" 2>/dev/null; then
        log_success "Spec 'failed_requirements' for '$cmd' is working as expected."
    else
        log_error "Spec 'failed_requirements' for '$cmd' did not fail as expected."
    fi
}   


log_info "Running requirements tests..."

# spec check pass
log_info "Spec check pass for commands and versions"
spec_check_version "bash" "4.0"
spec_check_version "curl" "7.58.0"
spec_version_compare "1.2.3" "1.2.0"
spec_version_compare "1.2.0" "1.2.3"
spec_check_requirements "curl" "bash:4.0" "command:1.0"

# spec check fail
spec_failed_check_version "non_existent_command" "1.0"
spec_failed_requirements "bash" "5.0"