#!/usr/bin/env bash
set -euo pipefail

# FIXME this module hasn't been fully tested

function yum_list_installed() {
    echo_do "yum: Listing packages..."
    ${YP_SUDO:-} yum list installed
    echo_done
}

function yum_cache_prune() {
    echo_do "yum: Pruning cache..."
    ${YP_SUDO:-} yum clean all
    ${YP_SUDO:-} rm -rf /var/cache/yum/*
    echo_done
}

function yum_update() {
    echo_do "yum: Updating..."
    # see https://unix.stackexchange.com/a/372586/61053
    ${YP_SUDO:-} yum -y clean expire-cache
    # NOTE 100 means packages are available for update
    ${YP_SUDO:-} yum -y check-update >/dev/null || {
        local EXIT_STATUS=$?
        # NOTE 100 means packages are available for update
        [[ "${EXIT_STATUS}" = "100" ]] || exit ${EXIT_STATUS}
    }
    echo_done
}

function yum_install_one() {
    local PKG="$1"

    local BREW_VSN=$(echo "${PKG}@" | cut -d"@" -f2)
    [[ -z "${BREW_VSN}" ]] || {
        echo_err "Passing a major version á la Homebrew is not yet implemented."
        exit 1
    }

    echo_do "yum: Installing ${PKG}..."
    ${YP_SUDO:-} yum -y install ${PKG}
    echo_done
    hash -r
}

function yum_install_one_unless() {
    local PKG="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "yum: Installing ${PKG}..."
    else
        yum_install_one "${PKG}"
        >&2 debug_exe "${EXECUTABLE}"
        exe_and_grep_q "$@"
    fi
}
