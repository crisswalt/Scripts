#!/bin/bash

# Colors
declare -gr CYAN='\033[0;36m'
declare -gr GREEN='\033[0;32m'
declare -gr YELLOW='\033[0;33m'
declare -gr RED='\033[0;31m'
declare -gr BLUE='\033[0;34m'
declare -gr PURPLE='\033[0;35m'
declare -gr BLACK='\033[0;30m'
declare -gr LIGHT_BLUE='\033[0;94m'
declare -gr LIGHT_GREEN='\033[0;92m'
declare -gr LIGHT_YELLOW='\033[0;93m'
declare -gr LIGHT_RED='\033[0;91m'
declare -gr LIGHT_PURPLE='\033[0;95m'
declare -gr LIGHT_BLACK='\033[0;90m'
declare -gr LIGHT_GRAY='\033[0;37m'
declare -gr DARK_GRAY='\033[1;30m'
declare -gr BRIGHT='\033[1m'
declare -gr GRAY='\033[0;90m'
declare -gr WHITE='\033[0;37m'
declare -gr RESET='\033[0m'
declare -gr BOLD='\033[1m'
declare -gr DIM='\033[2m'
declare -gr UNDERLINE='\033[4m'
declare -gr BLINK='\033[5m'
declare -gr REVERSE='\033[7m'
declare -gr HIDDEN='\033[8m'

declare -gA COLORS=(
    [cyan]="$CYAN"
    [green]="$GREEN"
    [yellow]="$YELLOW"
    [red]="$RED"
    [blue]="$BLUE"
    [purple]="$PURPLE"
    [black]="$BLACK"
    [light_blue]="$LIGHT_BLUE"
    [light_green]="$LIGHT_GREEN"
    [light_yellow]="$LIGHT_YELLOW"
    [light_red]="$LIGHT_RED"
    [light_purple]="$LIGHT_PURPLE"
    [light_black]="$LIGHT_BLACK"
    [light_gray]="$LIGHT_GRAY"
    [dark_gray]="$DARK_GRAY"
    [bright]="$BRIGHT"
    [gray]="$GRAY"
    [white]="$WHITE"
    [dark_gray]="$DARK_GRAY"
)

declare -gA STYLES=(
    [reset]="$RESET"
    [bold]="$BOLD"
    [dim]="$DIM"
    [underline]="$UNDERLINE"
    [blink]="$BLINK"
    [reverse]="$REVERSE"
    [hidden]="$HIDDEN"
)

declare -gA __downloaded_files=()
declare -gA __imported_scripts=()

# function require
# This function fetches a file from a given URL and returns its content.
# Use: require "path/to/file"
# Returns the content of the file or an error message if the fetch fails.
# Exceptions:
# - If the URL is invalid or the file cannot be fetched, it prints an error message
#   and returns an empty string.
require() {
    local baseurl=${BASEURL:-"https://raw.githubusercontent.com/crisswalt/Scripts/main"}
    local path="$1"

    if [[ -z "$path" ]]; then
        log_error "No path provided for require."
        return 1
    fi

    if [[ -n "${__downloaded_files[$path]}" ]]; then
        if [ "$VERBOSE" == "true" ]; then
            log_info "File '$path' already downloaded."
        fi
        echo "${__downloaded_files[$path]}"
        return 0
    fi

    local file=$(curl -fsSL "${baseurl}/${path}" 2>/dev/null)

    if [[ $? -ne 0 || -z "$file" ]]; then
        declare -A __errors=(
            [es]="No se pudo conectar. Por favor, verifica tu conexión a internet o la URL"
            [fr]="Échec de la connexion. Veuillez vérifier votre connexion Internet ou l'URL"
            [de]="Verbindung fehlgeschlagen. Bitte überprüfen Sie Ihre Internetverbindung oder die URL"
            [pt]="Falha na conexão. Verifique sua conexão com a internet ou a URL"
            [it]="Connessione fallita. Controlla la tua connessione a Internet o l'URL"
            [jp]="接続に失敗しました。インターネット接続またはURLを確認してください"
            [zh]="连接失败。请检查您的互联网连接或URL"
            [ru]="Не удалось подключиться. Пожалуйста, проверьте ваше интернет-соединение или URL"
            [ko]="연결 실패. 인터넷 연결 또는 URL을 확인하세요"
            [ar]="فشل الاتصال. يرجى التحقق من اتصال الإنترنت أو عنوان URL"
            [hi]="त्कनेक्शन विफल। कृपया अपने इंटरनेट कनेक्शन या URL की जांच करें"
            [tr]="Bağlantı başarısız oldu. Lütfen internet bağlantınızı veya URL'yi kontrol edin"
            [nl]="Verbinding mislukt. Controleer uw internetverbinding of de URL"
            [pl]="Połączenie nie powiodło się. Sprawdź swoje połączenie internetowe lub URL"
            [sv]="Anslutning misslyckades. Kontrollera din internetanslutning eller URL"
            [fi]="Yhteys epäonnistui. Tarkista internet-yhteytesi tai URL-osoite"
            [da]="Forbindelse mislykkedes. Tjek din internetforbindelse eller URL"
            [en]="Connection failed. Please check your internet connection or the URL"
        )
        local lang_code="${LANG:0:2}"
        if [[ -z "$lang_code" || -z "${__errors[$lang_code]}" ]]; then
            lang_code="en"
        fi
        log_error "${__errors[$lang_code]} (${baseurl}/${path})" 
        return 1
    fi

    __downloaded_files["$path"]="$file"

    echo "$file"
}


# function import
# This function imports a script from a given path using the require function.
# It sources the content of the script.
# Use: import "path/to/script.sh"
# Returns the content of the script or an error message if the import fails.
# Inherits:
# - require: to fetch the script content.
import() {
    local path="$1"

    if [[ -z "$path" ]]; then
        log_error "No path provided for import."
        return 1
    fi

    if [[ -n "${__imported_scripts[$path]}" ]]; then
        if [ "$VERBOSE" == "true" ]; then
            log_info "Script '$path' already imported."
        fi
        return 0
    fi

    if ! source <(require "$path"); then
        log_error "Failed to import script '$path'."
        return 1
    fi

    if [ "$VERBOSE" == "true" ]; then
        log_info "Script '$path' imported successfully."
    fi
    
    __imported_scripts["$path"]=1

    # Remove code from the downloaded variable that is no longer needed
    unset __downloaded_files["$path"]
}

# function log_error
# This function logs an error message in red color.
# Use: log_error "Your error message"
log_error() {
    local message="$1"
    echo -e "${RED}${BOLD}${message}${RESET}" >&2
}

# function log_warning
# This function logs a warning message in yellow color.
# Use: log_warning "Your warning message"
log_warning() {
    local message="$1"
    echo -e "${YELLOW}${BOLD}${message}${RESET}" >&2
}

# function log_success
# This function logs a success message in green color.
# Use: log_success "Your success message"
log_success() {
    local message="$1"
    echo -e "${GREEN}${BOLD}${message}${RESET}" >&2
}

# function log_info
# This function logs an informational message in blue color.
# Use: log_info "Your informational message"
log_info() {
    local message="$1"
    echo -e "${BLUE}${BOLD}${message}${RESET}" >&2
}

# Function clear_bootstrap_caches
# This function clears the caches of downloaded files and imported scripts.
# Use: clear_bootstrap_caches
# Returns: None
# Example: clear_bootstrap_caches
clear_bootstrap_caches() {
    __downloaded_files=()
    __imported_scripts=()

    if [ "$VERBOSE" == "true" ]; then
        log_info "Bootstrap caches cleared."
    fi
}

view_colors() {
    echo -e "${CYAN}Available Colors:${RESET}"
    for color in "${!COLORS[@]}"; do
        echo -e "${COLORS[$color]}$color${RESET}"
    done

    echo -e "\n${CYAN}Available Styles:${RESET}"
    for style in "${!STYLES[@]}"; do
        echo -e "${STYLES[$style]}$style${RESET}"
    done
}