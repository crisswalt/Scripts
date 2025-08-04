#!/bin/bash

#/**
# * Filename: Scripts/test-bootstrap.sh
# * Test script for the bootstrap functionality of the Scripts repository
# * This script tests the import and error handling of the bootstrap script.
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

spec_require_about_me() {
    local about_me_content="$(require "about.me" 2>&1)"
    if [[ "$about_me_content" == *"Script project executed from Github by Crisswalt"* ]]; then
        log_success "Spec 'about.me' is working as expected."
    else
        log_error "Spec 'about.me' did not match expected content."
    fi
}   

spec_require_about_me

spec_import_error() {
    LANG="$1"
    local failed_import="$(import "non_existent_script.sh" 2>&1)"
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

    local message_spec_error="${__errors[$LANG]:-"Language not supported"}"

    if [[ "$failed_import" == *"$message_spec_error"* ]]; then
        log_success "Spec 'message error' for '$LANG' is working as expected."
    else
        log_error "Spec 'message error' for '$LANG' did not match expected error."
    fi
}


spec_import_error "es"
spec_import_error "fr"
spec_import_error "de"
spec_import_error "pt"
spec_import_error "it"
spec_import_error "jp"
spec_import_error "zh"
spec_import_error "ru"
spec_import_error "ko"
spec_import_error "ar"
spec_import_error "hi"
spec_import_error "tr"
spec_import_error "nl"
spec_import_error "pl"
spec_import_error "sv"
spec_import_error "fi"
spec_import_error "da"
spec_import_error "en"