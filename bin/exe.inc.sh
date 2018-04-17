#!/usr/bin/env bash
set -euo pipefail

export PATH=/usr/local/opt/coreutils/libexec/gnubin:${PATH}
export PATH=/usr/local/opt/gnu-sed/libexec/gnubin:${PATH}
export PATH=/usr/local/opt/gnu-tar/libexec/gnubin:${PATH}
[ ! -e /usr/local/opt/gnu-which/bin/gwhich ] || {
    function which() {
        /usr/local/opt/gnu-which/bin/gwhich $@
    }
}

export PATH=/usr/local/bin:${PATH}
export PATH=${HOME}/.local/bin:${PATH}

# ------------------------------------------------------------------------------

export CI_ECHO=${SUPPORT_FIRECLOUD_DIR}/bin/ci-echo

function echo_next() {
    ${CI_ECHO} "[NEXT]" "$@"
}

function echo_do() {
    ${CI_ECHO} "[DO  ]" "$@"
}

function echo_done() {
    ${CI_ECHO} "[DONE]" "$@"
}

function echo_info() {
    ${CI_ECHO} "[INFO]" "$@"
}

function echo_skip() {
    ${CI_ECHO} "[SKIP]" "$@"
}

function echo_warn() {
    ${CI_ECHO} "[WARN]" "$@"
}

function echo_err() {
    ${CI_ECHO} "[ERR ]" "$@"
}

# ------------------------------------------------------------------------------

function sh_script_usage() {
    grep "^##" "${0}" | cut -c 4-
    exit 1
}

function sh_script_version() {
    grep "^#-" "${0}" | cut -c 4-
    exit 1
}

# ------------------------------------------------------------------------------

function exe() {
    echo "$(pwd)\$ $@"
    "$@"
}

function printenv_uniq() {
    tac | sort -u -t= -k1,1 | sed "/=$$/d" | sed "/=%/d" | sed "/^$$/d"
}

function printenv_with_name() {
    for f in $*; do
        echo "${f}=$(printenv ${f} || echo "")"
    done
}
