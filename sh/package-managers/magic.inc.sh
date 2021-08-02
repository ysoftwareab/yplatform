#!/usr/bin/env bash
set -euo pipefail

function magic_name_vsn {
    local IFS="@"
    echo "$*"
}

function magic_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v apk >/dev/null 2>&1; then
        echo "apk"
    fi
}

function magic_update() {
    local PACKAGE_MANAGER=$(magic_package_manager)
    echo_info "magic: Using ${PACKAGE_MANAGER}."

    echo_do "magic: Updating..."
    ${PACKAGE_MANAGER}_update
    echo_done
}

function magic_map_package_name() {
    local PACKAGE_MANAGER=$1
    local PKG="$2"
    local NAME=$(echo "${PKG}" | cut -d"@" -f1)
    local VSN=$(echo "${PKG}@" | cut -d"@" -f2)

    case ${NAME}@${PACKAGE_MANAGER} in
        poppler@*)
            NEW_NAME=poppler-utils
            ;;
        *)
            echo "${PKG}"
            return
            ;;
    esac

    echo_info "magic: Using ${NEW_NAME} instead of ${NAME} for ${PACKAGE_MANAGER}."
    PKG="$(magic_name_vsn ${NEW_NAME} ${VSN})"
    echo "${PKG}"
}

# expects package name for 'brew', and maps to corresponding alternatives
function magic_install_one() {
    local PACKAGE_MANAGER=$(magic_package_manager)
    echo_info "magic: Using ${PACKAGE_MANAGER}."

    local PKG="$1"
    # PKG may contain version 'name@version'
    local NAME=$(echo "${PKG}" | cut -d"@" -f1)
    local VSN=$(echo "${PKG}@" | cut -d"@" -f2)

    NAME_SUFFIX="$(echo "${NAME}" | tr "[:lower:]" "[:upper:]" | sed "s/[^A-Z0-9]\{1,\}/_/g" | sed "s/^_//" | sed "s/_$//")" # editorconfig-checker-disable-line

    echo_do "magic: Installing ${PKG}..."
    if [[ "$(type -t "magic_install_${NAME_SUFFIX}")" = "function" ]]; then
        eval "magic_install_${NAME_SUFFIX} '${PACKAGE_MANAGER}' '${VSN}'"
    else
        PKG="$(magic_map_package_name "${PACKAGE_MANAGER}" "${PKG}")"
        eval "${PACKAGE_MANAGER}_install_one '${PKG}'"
    fi
    echo_done
    hash -r # see https://github.com/Homebrew/brew/issues/5013
}

function magic_install_one_if() {
    local PKG="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "magic: Installing ${PKG}..."
    else
        magic_install_one "${PKG}"
        >&2 exe_debug "${EXECUTABLE}"
        exe_and_grep_q "$@"
    fi
}
