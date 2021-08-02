#!/usr/bin/env bash
set -euo pipefail

# FIXME this module hasn't been fully tested

# pacman-* functions are not related to brew,
# but they are here for convenience, to make them available in Brewfile.inc.sh files

function pacman_update() {
    ${SF_SUDO:-} pacman -Syy
}

function pacman_install_one() {
    local PKG="$*"

    local BREW_VSN=$(echo "${PKG}@" | cut -d"@" -f2)
    [[ -z "${BREW_VSN}" ]] || {
        echo_err "Passing a major version á la Homebrew is not yet implemented."
        exit 1
    }

    echo_do "pacman: Installing ${PKG}..."
    ${SF_SUDO:-} pacman -S --noconfirm ${PKG}
    echo_done
    hash -r # see https://github.com/Homebrew/brew/issues/5013
}

function pacman_install_one_if() {
    local FORMULA="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "pacman: Installing ${FORMULA}..."
    else
        pacman_install_one "${FORMULA}"
        >&2 exe_debug "${EXECUTABLE}"
        exe_and_grep_q "$@"
    fi
}
