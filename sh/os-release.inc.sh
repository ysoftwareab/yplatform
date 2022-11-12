#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

case ${OS_SHORT} in
    darwin)
        OS_RELEASE_VERSION_ID=$(sw_vers -productVersion)
        # OS_RELEASE_VERSION_ID=$(sysctl -n kern.osproductversion)

        SETUP_ASSISTANT_APP_DIR="/System/Library/CoreServices/Setup Assistant.app"
        OS_RELEASE_ID_CODENAME=$(cat "${SETUP_ASSISTANT_APP_DIR}/Contents/Resources/en.lproj/OSXSoftwareLicense.html" | grep "SOFTWARE LICENSE AGREEMENT FOR" | sed "s/.*FOR //" | sed "s/<.*//") # editorconfig-checker-disable-line
        OS_RELEASE_ID=$(echo "${OS_RELEASE_ID_CODENAME}" | cut -d" " -f1 | tr "[:upper:]" "[:lower:]")
        # shellcheck disable=SC2018
        OS_RELEASE_VERSION_CODENAME=$(echo "${OS_RELEASE_ID_CODENAME}" | cut -d" " -f2- | tr "[:upper:]" "[:lower:]" | tr -cd "a-z") # editorconfig-checker-disable-line
        unset SETUP_ASSISTANT_APP_DIR
        unset OS_RELEASE_ID_CODENAME
        ;;
    linux)
        # see https://unix.stackexchange.com/a/6348/61053
        if [[ -e /etc/os-release ]]; then
            # shellcheck disable=SC1091
            OS_RELEASE_ID=$(source /etc/os-release && echo ${ID:-} | tr "[:upper:]" "[:lower:]")
            # shellcheck disable=SC1091
            OS_RELEASE_VERSION_ID=$(source /etc/os-release && echo ${VERSION_ID:-0} | tr "[:upper:]" "[:lower:]")
            # shellcheck disable=SC1091
            OS_RELEASE_VERSION_CODENAME=$(source /etc/os-release && echo ${VERSION_CODENAME:-} | tr "[:upper:]" "[:lower:]") # editorconfig-checker-disable-line
        elif type lsb_release >/dev/null 2>&1; then
            # linuxbase.org
            OS_RELEASE_ID=$(lsb_release -si | tr "[:upper:]" "[:lower:]")
            OS_RELEASE_VERSION_ID=$(lsb_release -sr)
            OS_RELEASE_VERSION_CODENAME=$(lsb_release -sc | tr "[:upper:]" "[:lower:]")
        elif [[ -f /etc/lsb-release ]]; then
            # shellcheck disable=SC1091
            OS_RELEASE_ID=$(source /etc/lsb-release && echo ${DISTRIB_ID:-} | tr "[:upper:]" "[:lower:]")
            # shellcheck disable=SC1091
            OS_RELEASE_VERSION_ID=$(source /etc/lsb-release && echo ${DISTRIB_RELEASE:-0} | tr "[:upper:]" "[:lower:]")
            # shellcheck disable=SC1091
            OS_RELEASE_VERSION_CODENAME=$(source /etc/lsb-release && echo ${DISTRIB_CODENAME:-} | tr "[:upper:]" "[:lower:]") # editorconfig-checker-disable-line
        fi
        ;;
    *)
        OS_RELEASE_ID=
        OS_RELEASE_VERSION_ID=0
        OS_RELEASE_VERSION_CODENAME=
        ;;
esac
