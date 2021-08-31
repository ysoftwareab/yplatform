#!/usr/bin/env bash
set -euo pipefail

function apt_list_installed() {
    echo_do "aptitude: Listing packages..."
    ${SF_SUDO:-} apt list --installed
    echo_done
}

function apt_cache_prune() {
    echo_do "apt: Pruning cache..."
    ${SF_SUDO:-} apt-get clean
    ${SF_SUDO:-} rm -rf /var/lib/apt/lists/*
    echo_done
}

function apt_update() {
    echo_do "aptitude: Updating..."
    ${SF_SUDO:-} apt-get -y --fix-missing update 2>&1 || {
        set -x
        # try to handle "Hash Sum mismatch" error
        ${SF_SUDO:-} apt-get clean
        ${SF_SUDO:-} rm -rf /var/lib/apt/lists/*
        # see https://bugs.launchpad.net/ubuntu/+source/apt/+bug/1785778
        ${SF_SUDO:-} apt-get -o Acquire::CompressionTypes::Order::=gz update
        ${SF_SUDO:-} apt-get -y --fix-missing update
        set +x
    }
    echo_done
}

APT_GET_FORCE_YES=()
APT_GET_FORCE_YES+=("--allow-downgrades")
APT_GET_FORCE_YES+=("--allow-remove-essential")
APT_GET_FORCE_YES+=("--allow-change-held-packages")
APT_DPKG=()
[[ "${CI:-}" != "true" ]] || {
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y "${APT_GET_FORCE_YES[@]}" --dry-run apt >/dev/null 2>&1 || \
        APT_GET_FORCE_YES=("--force-yes")
    [[ -n "$(ls -A "/etc/apt/apt.conf.d" 2>/dev/null)" ]] && cat /etc/apt/apt.conf.d/* | grep -q "force-confdef" || \
        APT_DPKG+=("-o" "Dpkg::Options::=--force-confdef")
    [[ -n "$(ls -A "/etc/apt/apt.conf.d" 2>/dev/null)" ]] && cat /etc/apt/apt.conf.d/* | grep -q "force-confold" || \
        APT_DPKG+=("-o" "Dpkg::Options::=--force-confold")
}
function apt_install_one() {
    local PKG="$1"

    local BREW_VSN=$(echo "${PKG}@" | cut -d"@" -f2)
    [[ -z "${BREW_VSN}" ]] || {
        echo_err "Passing a major version á la Homebrew is not yet implemented."
        exit 1
    }

    echo_do "aptitude: Installing ${PKG}..."
    ${SF_SUDO:-} apt-get -y "${APT_GET_FORCE_YES[@]}" "${APT_DPKG[@]}" install ${PKG}
    echo_done
    hash -r # see https://github.com/Homebrew/brew/issues/5013
}

function apt_install_one_if() {
    local PKG="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "aptitude: Installing ${PKG}..."
    else
        apt_install_one "${PKG}"
        >&2 debug_exe "${EXECUTABLE}"
        exe_and_grep_q "$@"
    fi
}
