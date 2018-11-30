#!/usr/bin/env bash
set -euo pipefail

if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    export PATH=/home/linuxbrew/.linuxbrew/sbin:${PATH}
    export PATH=/home/linuxbrew/.linuxbrew/bin:${PATH}
elif [[ -x ~/.linuxbrew/bin/brew ]]; then
    export PATH=~/.linuxbrew/sbin:${PATH}
    export PATH=~/.linuxbrew/bin:${PATH}
fi
export PATH=/usr/local/sbin:${PATH}
export PATH=/usr/local/bin:${PATH}
export PATH=${HOME}/.local/sbin:${PATH}
export PATH=${HOME}/.local/bin:${PATH}

if which brew >/dev/null 2>&1; then
    HOMEBREW_PREFIX=$(brew --prefix)
    export PATH=${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:${PATH}

    for f in coreutils findutils gnu-sed gnu-tar gnu-time gnu-which grep gzip; do
        export PATH=${HOMEBREW_PREFIX}/opt/${f}/libexec/gnubin:${PATH}
    done
    export PATH=${HOMEBREW_PREFIX}/opt/make/bin:${PATH}
    export PATH=${HOMEBREW_PREFIX}/opt/unzip/bin:${PATH}
    alias which=${HOMEBREW_PREFIX}/opt/gnu-which/bin/gwhich
    unset HOMEBREW_PREFIX
fi

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

function exe_and_grep_q() {
    local OUTPUT=$(eval "$1")
    echo_info "Testing if '${OUTPUT}' matches '$2'..."
    echo "${OUTPUT}" | grep -q "$2" || {
        echo_err "No match."
        exit 1
    }
}
