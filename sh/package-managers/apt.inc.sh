#!/usr/bin/env bash
set -euo pipefail

function apt_list_installed() {
    echo_do "aptitude: Listing packages..."
    ${YP_SUDO:-} apt list --installed
    echo_done
}

function apt_cache_prune() {
    echo_do "apt: Pruning cache..."
    ${YP_SUDO:-} apt-get clean
    ${YP_SUDO:-} rm -rf /var/lib/apt/lists/*
    echo_done
}

function apt_update() {
    echo_do "aptitude: Updating..."
    ${YP_SUDO:-} apt-get -y --fix-missing update 2>&1 || {
        set -x
        # try to handle "Hash Sum mismatch" error
        ${YP_SUDO:-} apt-get clean
        ${YP_SUDO:-} rm -rf /var/lib/apt/lists/*
        # see https://bugs.launchpad.net/ubuntu/+source/apt/+bug/1785778
        ${YP_SUDO:-} apt-get -o Acquire::CompressionTypes::Order::=gz update
        ${YP_SUDO:-} apt-get -y --fix-missing update
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
    export DEBCONF_NONINTERACTIVE_SEEN=true
    apt-get install -y "${APT_GET_FORCE_YES[@]}" --dry-run apt >/dev/null 2>&1 || \
        APT_GET_FORCE_YES=("--force-yes")
    [[ -z "$(ls -A "/etc/apt/apt.conf.d" 2>/dev/null)" ]] || cat /etc/apt/apt.conf.d/* | grep -q "force-confdef" || \
        APT_DPKG+=("-o" "Dpkg::Options::=--force-confdef")
    [[ -z "$(ls -A "/etc/apt/apt.conf.d" 2>/dev/null)" ]] || cat /etc/apt/apt.conf.d/* | grep -q "force-confold" || \
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
    if [[ -n "${YP_SUDO:-}" ]]; then
        ${YP_SUDO:-} --preserve-env --set-home apt-get -y "${APT_GET_FORCE_YES[@]}" "${APT_DPKG[@]}" install ${PKG} || {
            echo_err "apt-get install failed. Running with -o Debug::pkgProblemResolver=true for more info."
            [[ -z "$(ls -A "/etc/apt/apt.conf.d" 2>/dev/null)" ]] || \
                cat /etc/apt/apt.conf.d/* | grep -q "pkgProblemResolver" || {
                    APT_DPKG+=("-o" "Debug::pkgProblemResolver=true")
                    ${YP_SUDO:-} --preserve-env --set-home \
                        apt-get -y "${APT_GET_FORCE_YES[@]}" "${APT_DPKG[@]}" install ${PKG}
                }
        }

    else
        apt-get -y "${APT_GET_FORCE_YES[@]}" "${APT_DPKG[@]}" install ${PKG} ||  {
            echo_err "apt-get install failed. Running with -o Debug::pkgProblemResolver=true for more info."
            [[ -z "$(ls -A "/etc/apt/apt.conf.d" 2>/dev/null)" ]] || \
                cat /etc/apt/apt.conf.d/* | grep -q "pkgProblemResolver" || {
                    APT_DPKG+=("-o" "Debug::pkgProblemResolver=true")
                    apt-get -y "${APT_GET_FORCE_YES[@]}" "${APT_DPKG[@]}" install ${PKG}
                }
        }
    fi
    echo_done
    hash -r # see https://github.com/Homebrew/brew/issues/5013
}

function apt_install_one_unless() {
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
