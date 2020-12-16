#!/usr/bin/env bash
set -euo pipefail

source ${SUPPORT_FIRECLOUD_DIR}/sh/exe-env.inc.sh

SF_CI_ECHO_BENCHMARK=${SF_CI_ECHO_BENCHMARK:-/dev/null}
export CI_ECHO="${SUPPORT_FIRECLOUD_DIR}/bin/ci-echo --benchmark ${SF_CI_ECHO_BENCHMARK}"

function echo_next() {
    ${CI_ECHO} "[NEXT]" "$@"
}

function echo_do() {
    ${CI_ECHO} "[DO  ]" "$@"
}

# shellcheck disable=SC2120
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
    echo "$(pwd)\$ $*"
    "$@"
}

function printenv_uniq() {
    tac | sort -u -t= -k1,1 | sed "/=$$/d" | sed "/=%/d" | sed "/^$$/d"
}

function printenv_with_name() {
    for f in "$@"; do
        echo "${f}=$(printenv ${f} || echo "")"
    done
}

function exe_and_grep_q() {
    local CMD="$1"
    shift
    local EXECUTABLE=$(echo "${CMD}" | cut -d" " -f1)
    local OUTPUT=$(eval "${CMD}")
    local OUTPUT_EXPECTED="$1"
    shift
    echo_do "Testing if command '${CMD}' with output '${OUTPUT}' matches $* '${OUTPUT_EXPECTED}'..."
    if [[ $(type -t ${EXECUTABLE}) = "file" ]]; then
        which -a ${EXECUTABLE}
        which -a ${EXECUTABLE} | while read -r EXECUTABLE_PATH; do
            echo "${EXECUTABLE_PATH}" | grep -q "^/" || continue
            ls -l "${EXECUTABLE_PATH}"
        done
        type ${EXECUTABLE} || true
    else
        echo "${EXECUTABLE} is $(type -t ${EXECUTABLE} || true)"
    fi
    echo "${OUTPUT}" | grep -q "$@" "${OUTPUT_EXPECTED}" || {
        echo_err "Command '${CMD}' with output '${OUTPUT}' matches $* '${OUTPUT_EXPECTED}'."
        return 1
    }
    echo_done
}

function prompt_q_to_continue() {
    local Q="${1:-Are you sure you want to continue?}"
    local CANCEL_KEY="${2:-Ctrl-C}"
    echo "[Q   ] ${Q}"
    echo "       Press ENTER to Continue."
    echo "       Press ${CANCEL_KEY} to Cancel."
    if [[ "${CI:-}" = "true" ]]; then
        echo_info "CI pressed ENTER."
        return 0
    fi
    read -r -p "" -n1
    echo
    [[ "${REPLY}" != "${CANCEL_KEY}" ]]
}
