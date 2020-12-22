#!/usr/bin/env bash
set -euo pipefail

# apt-* functions are not related to brew,
# but they are here for convenience, to make them available in Brewfile.inc.sh files

function apt_update() {
    ${SF_SUDO} apt-get update -y --fix-missing 2>&1 || {
        set -x
        # try to handle "Hash Sum mismatch" error
        ${SF_SUDO} apt-get clean
        ${SF_SUDO} rm -rf /var/lib/apt/lists/*
        # see https://bugs.launchpad.net/ubuntu/+source/apt/+bug/1785778
        ${SF_SUDO} apt-get update -o Acquire::CompressionTypes::Order::=gz
        ${SF_SUDO} apt-get update -y --fix-missing
        set +x
    }
}

function apt_install_one() {
    local FORCE_YES="--allow-downgrades --allow-remove-essential --allow-change-held-packages"
    local DPKG="$*"

    echo_do "aptitude: Installing ${DPKG}..."
    # ${SF_SUDO} apt-get install -y --force-yes ${DPKG}
    ${SF_SUDO} apt-get install -y ${FORCE_YES} ${DPKG}
    echo_done
    hash -r # see https://github.com/Homebrew/brew/issues/5013
}

function apt_install_one_if() {
    local FORMULA="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "aptitude: Installing ${FORMULA}..."
    else
        apt_install_one "${FORMULA}"
        >&2 exe_and_grep_q "$@"
    fi
    exe_debug "${EXECUTABLE}"
}
