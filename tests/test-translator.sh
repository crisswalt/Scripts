#!/bin/bash

# Filename: Scripts/test-translator.sh

# Load environment variables if .env file exists
[ -f ".env" ] && source .env

# Import bootstrap script from the specified BASEURL
BASEURL=${BASEURL:-"https://raw.githubusercontent.com/crisswalt/Scripts/main"}
if ! source <(curl -fsSL "${BASEURL}/bootstrap.sh"); then
    echo -e "\e[0;31mError: Failed to import scripts from ${BASEURL}.\e[0m" >&2
    exit 1
fi

import "utilities/translator.sh"

echo "=== Testing translator.sh ==="
echo "Script: $(basename "$0")"
echo "Current LANG: $LANG"
echo

echo "Testing translation:"
echo "  Input: 'Hello world!'"
echo "  Output: $(trans "Hello world!")"
echo

echo "Testing fallback (untranslated):"
echo "  Input: 'Untranslated text'"
echo "  Output: $(trans "Untranslated text")"

key="pi"
value="3.14"
echo
echo "Testing variable substitution:"
echo "  Input: 'Value of \$key is '\$value''"
echo "  Output: $(trans "Value of \$key is '\$value'")"
echo