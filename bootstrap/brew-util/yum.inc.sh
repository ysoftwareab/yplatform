#!/usr/bin/env bash
set -euo pipefail

# FIXME this module hasn't been fully tested

# yum-* functions are not related to brew,
# but they are here for convenience, to make them available in Brewfile.inc.sh files

function yum_update() {
    # see https://unix.stackexchange.com/a/372586/61053
    ${SF_SUDO} yum -y clean expire-cache
    ${SF_SUDO} yum -y check-update >/dev/null
}

function yum_install_one() {
    local PKG="$1"

    local BREW_VSN=$(echo "${PKG}@" | cut -d"@" -f2)
    [[ -z "${BREW_VSN}" ]] || {
        echo_err "Passing a major version á la Homebrew is not yet implemented."
        exit 1
    }

    echo_do "yum: Installing ${PKG}..."
    ${SF_SUDO} yum -y install ${PKG}
    echo_done
    hash -r # see https://github.com/Homebrew/brew/issues/5013
}

function yum_install_one_if() {
    local PKG="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "yum: Installing ${PKG}..."
    else
        yum_install_one "${PKG}"
        >&2 exe_debug "${EXECUTABLE}"
        exe_and_grep_q "$@"
    fi
}
