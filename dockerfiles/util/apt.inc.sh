#!/usr/bin/env bash
set -euo pipefail

function apt_update() {
    apt-get update -y --fix-missing 2>&1 || {
        set -x
        # try to handle "Hash Sum mismatch" error
        apt-get clean
        rm -rf /var/lib/apt/lists/*
        # see https://bugs.launchpad.net/ubuntu/+source/apt/+bug/1785778
        apt-get update -o Acquire::CompressionTypes::Order::=gz
        apt-get update -y --fix-missing
        set +x
    }
}

APT_GET_FORCE_YES="--allow-downgrades --allow-remove-essential --allow-change-held-packages"
apt-get install -y ${APT_GET_FORCE_YES} --dry-run apt >/dev/null 2>&1 || \
    APT_GET_FORCE_YES="--force-yes"
function apt_install_one() {
    local DPKG="$*"
    apt-get install -y ${APT_GET_FORCE_YES} "${DPKG}"
}
