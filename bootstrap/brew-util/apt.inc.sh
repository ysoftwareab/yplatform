#!/usr/bin/env bash
set -euo pipefail

# apt-* functions are not related to brew,
# but they are here for convenience, to make them available in Brewfile.inc.sh files

function apt_update() {
    ${SUDO} apt-get update -y --fix-missing 2>&1 || {
        set -x
        # try to handle "Hash Sum mismatch" error
        ${SUDO} apt-get clean
        ${SUDO} rm -rf /var/lib/apt/lists/*
        # see https://bugs.launchpad.net/ubuntu/+source/apt/+bug/1785778
        ${SUDO} apt-get update -o Acquire::CompressionTypes::Order::=gz
        ${SUDO} apt-get update -y --fix-missing
        set +x
    }
}

function apt_install_one() {
    local DPKG="$@"

    echo_do "aptitude: Installing ${DPKG}..."
    # ${SUDO} apt-get install -y --force-yes ${DPKG}
    ${SUDO} apt-get install -y ${FORCE_YES} ${DPKG}
    echo_done
}

function apt_install() {
    local FORCE_YES="--allow-downgrades --allow-remove-essential --allow-change-held-packages"
    while read -r -u3 DPKG; do
        [[ -n "${DPKG}" ]] || continue
        apt_install_one ${DPKG}
    done 3< <(echo "$@")
}
