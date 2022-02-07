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

function magic_list_installled() {
    local PACKAGE_MANAGER=$(magic_package_manager)
    echo_do "magic: Listing packages using ${PACKAGE_MANAGER}..."
    ${PACKAGE_MANAGER}_list_installed
    echo_done
}

function magic_cache_prune() {
    local PACKAGE_MANAGER=$(magic_package_manager)
    echo_do "magic: Pruning cache using ${PACKAGE_MANAGER}..."
    ${PACKAGE_MANAGER}_cache_prune
    echo_done
}

function magic_update() {
    local PACKAGE_MANAGER=$(magic_package_manager)
    echo_do "magic: Updating using ${PACKAGE_MANAGER}..."
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
    local PKG="$1"
    # PKG may contain version 'name@version'
    local NAME=$(echo "${PKG}" | cut -d"@" -f1)
    local VSN=$(echo "${PKG}@" | cut -d"@" -f2)

    NAME_SUFFIX="$(echo "${NAME}" | tr "[:lower:]" "[:upper:]" | sed "s/[^A-Z0-9]\{1,\}/_/g" | sed "s/^_//" | sed "s/_$//")" # editorconfig-checker-disable-line

    echo_do "magic: Installing ${PKG} using ${PACKAGE_MANAGER}..."
    if [[ "$(type -t "magic_install_${NAME_SUFFIX}" || true)" = "function" ]]; then
        eval "magic_install_${NAME_SUFFIX} '${PACKAGE_MANAGER}' '${VSN}'"
    else
        PKG="$(magic_map_package_name "${PACKAGE_MANAGER}" "${PKG}")"
        eval "${PACKAGE_MANAGER}_install_one '${PKG}'"
    fi
    echo_done
    hash -r
}

function magic_install_one_unless() {
    local PACKAGE_MANAGER=$(magic_package_manager)
    local PKG="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "magic: Installing ${PKG} using ${PACKAGE_MANAGER}..."
    else
        magic_install_one "${PKG}"
        >&2 debug_exe "${EXECUTABLE}"
        exe_and_grep_q "$@"
    fi
}
