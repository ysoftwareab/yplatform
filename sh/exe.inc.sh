#!/usr/bin/env bash
set -euo pipefail

# ECHO -------------------------------------------------------------------------

SF_CI_ECHO_BENCHMARK=${SF_CI_ECHO_BENCHMARK:-/dev/null}
export SF_CI_ECHO="${SUPPORT_FIRECLOUD_DIR}/bin/ci-echo --benchmark ${SF_CI_ECHO_BENCHMARK}"

function echo_next() {
    ${SF_CI_ECHO} "[NEXT]" "$@"
}

function echo_do() {
    ${SF_CI_ECHO} "[DO  ]" "$@"
}

# shellcheck disable=SC2120
function echo_done() {
    ${SF_CI_ECHO} "[DONE]" "$@"
}

function echo_info() {
    ${SF_CI_ECHO} "[INFO]" "$@"
}

function echo_skip() {
    ${SF_CI_ECHO} "[SKIP]" "$@"
}

function echo_warn() {
    ${SF_CI_ECHO} "[WARN]" "$@"
}

function echo_err() {
    ${SF_CI_ECHO} "[ERR ]" "$@"
}

# SHELL ------------------------------------------------------------------------

function sh_script_usage() {
    grep "^##" "${0}" | cut -c 4- | if command -v envsubst >/dev/null 2>&1; then envsubst; else cat; fi
    # return 1
    exit 1
}

function sh_script_version() {
    grep "^#-" "${0}" | cut -c 4- | if command -v envsubst >/dev/null 2>&1; then envsubst; else cat; fi
    # return 1
    exit 1
}

function sh_shellopts() {
    # usage: OLDOPTS="$(sh_shellopts)"; ...; sh_shellopts_restore "${OLDOPTS}"

    # see https://unix.stackexchange.com/a/383581/61053
    # see https://unix.stackexchange.com/a/476710/61053
    local OLDOPTS="$(set +o)"
    # bash resets errexit inside sub-shells like $(set +o) above
    [[ ! -o errexit ]] || OLDOPTS="${OLDOPTS}; set -e"
    if [[ -n "${BASH_VERSION:-}" ]]; then
        # bash-specific options
        OLDOPTS="${OLDOPTS}; $(shopt -p)"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        # zsh-specific options
        OLDOPTS="${OLDOPTS}; setopt $(setopt); unsetopt $(unsetopt)"
    fi
    return "${OLDOPTS}"
}

function sh_shellopts_restore() {
    set +vx
    eval "$1"
}

# EXE --------------------------------------------------------------------------

function exe() {
    >&2 echo "$(pwd)\$ $*"
    "$@"
}

function exe_and_grep_q() {
    local CMD="$1"
    shift
    local EXPECTED_STDOUT="$1"
    shift

    local EXECUTABLE="$(echo "${CMD}" | cut -d" " -f1)"
    local EXECUTABLE_TYPE="$(type -t ${EXECUTABLE} || echo "undefined")"
    local CMD_STDOUT="command not found: ${EXECUTABLE}"
    local CMD_STDERR="$(mktemp -t firecloud.XXXXXXXXXX)"
    if [[ "${EXECUTABLE_TYPE}" != "undefined" ]]; then
        CMD_STDOUT="$(eval "${CMD}" 2>${CMD_STDERR} || true)"
    fi

    if echo "${CMD_STDOUT}" | grep -q "${EXPECTED_STDOUT}"; then
        echo_info "Command '${CMD}' with stdout '${CMD_STDOUT}' matches '${EXPECTED_STDOUT}'."
    else
        echo_err "Command '${CMD}' with stdout '${CMD_STDOUT}' failed to match '${EXPECTED_STDOUT}'."
        echo_info "Command stderr: $(cat ${CMD_STDERR})"
        echo_info "Command's executable info:"
        >&2 debug_exe "${EXECUTABLE}"
        rm -f ${CMD_STDERR}
        return 1
    fi
    rm -f ${CMD_STDERR}
}

function unless_exe_and_grep_q() {
    local CMD="$1"
    shift
    local EXPECTED_STDOUT="$1"
    shift

    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    exe_and_grep_q "${CMD}" "${EXPECTED_STDOUT}" || {
        "$@"
        hash -r # see https://github.com/Homebrew/brew/issues/5013
        >&2 debug_exe "${EXECUTABLE}"
        exe_and_grep_q "${CMD}" "${EXPECTED_STDOUT}"
    }
}

function debug_exe() {
    local EXECUTABLE="$1"
    local EXECUTABLE_TYPE="$(type -t ${EXECUTABLE} || echo "undefined")"
    if [[ "${EXECUTABLE_TYPE}" = "file" ]]; then
        type -a ${EXECUTABLE}
        type -a -p ${EXECUTABLE} | while read -r EXECUTABLE_PATH; do \
            ls -l "${EXECUTABLE_PATH}"
        done
        type ${EXECUTABLE} || true
    else
        echo "PATH=${PATH}"
        echo "${EXECUTABLE} is ${EXECUTABLE_TYPE}."
    fi
}

# PRINTENV ---------------------------------------------------------------------

# list all shell variables' names, not just exported variables
function printenv_all_names() {
    compgen -A variable
}

# list shell variables, not just exported variables
function printenv_all() {
    local VARS="$*"
    [[ $# -ne 0 ]] || VARS="$(printenv_all_names | grep -v "^VARS$")"

    # not sure why, but printenv_all_names catches "undefined" vars e.g. BASH_ALIASES
    local NOUNSET_STATE="$(set +o | grep nounset)"
    set +u
    for VAR in ${VARS}; do
        echo "${VAR}=${!VAR}"
    done
    eval "${NOUNSET_STATE}"
}

# MISC -------------------------------------------------------------------------

function exit_allow_sigpipe() {
    local EXIT_STATUS=$?
    [[ ${EXIT_STATUS} -eq 141 ]] || exit ${EXIT_STATUS}
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
