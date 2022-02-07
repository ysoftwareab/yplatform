#!/usr/bin/env bash
set -euo pipefail

function apk_list_installed() {
    echo_do "apk: Listing packages..."
    ${YP_SUDO:-} apk list --installed
    echo_done
}

function apk_cache_prune() {
    echo_do "apk: Pruning cache..."
    rm -rf /var/cache/apk/*
    echo_done
}

function apk_update() {
    echo_do "apk: Updating..."
    ${YP_SUDO:-} apk update
    echo_done
}

function apk_install_one() {
    local PKG="$1"

    local BREW_VSN=$(echo "${PKG}@" | cut -d"@" -f2)
    [[ -z "${BREW_VSN}" ]] || {
        echo_err "Passing a major version á la Homebrew is not yet implemented."
        exit 1
    }

    echo_do "apk: Installing ${PKG}..."
    ${YP_SUDO:-} apk add --no-cache ${PKG}
    echo_done
    hash -r
}

function apk_install_one_unless() {
    local PKG="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "apk: Installing ${PKG}..."
    else
        apk_install_one "${PKG}"
        >&2 debug_exe "${EXECUTABLE}"
        exe_and_grep_q "$@"
    fi
}
