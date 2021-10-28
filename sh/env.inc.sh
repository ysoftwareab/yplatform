#!/usr/bin/env bash

[[ -n "${YP_DIR:-}" ]] || {
    if [[ -n "${BASH_VERSION:-}" ]]; then
        YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
        # echo >&2 YP_DIR=$YP_DIR
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        YP_DIR="$(cd "$(dirname ${(%):-%x})/.." && pwd)"
    else
        echo >&2 "Unsupported shell or \$BASH_VERSION and \$ZSH_VERSION are undefined."
        exit 1
    fi
}

function sf_path_prepend() {
    echo ":${PATH}:" | grep -q ":$1:" || export PATH=$1:${PATH}
    export PATH=$(echo "${PATH}" | sed "s|^:||" | sed "s|:$||")
}

function sf_path_prepend_after() {
    if echo ":${PATH}:" | grep -q ":$2:"; then
        export PATH=$(echo "${PATH}" | sed "s/:$2:/:$2:$1:/")
    else
        sf_path_prepend "$1"
    fi
    export PATH=$(echo "${PATH}" | sed "s|^:||" | sed "s|:$||")
}

function sf_path_append() {
    echo ":${PATH}:" | grep -q ":$1:" || export PATH=${PATH}:$1
    export PATH=$(echo "${PATH}" | sed "s|^:||" | sed "s|:$||")
}

function sf_path_append_before() {
    if echo ":${PATH}:" | grep -q ":$2:"; then
        export PATH=$(echo "${PATH}" | sed "s/:$2:/:$1:$2:/")
    else
        sf_path_append "$1"
    fi
    export PATH=$(echo "${PATH}" | sed "s|^:||" | sed "s|:$||")
}

[[ "${YP_DEV_INC_SH:-}" = "true" ]] || {
    source ${YP_DIR}/bin/sf-env
}

# NOTE caveat: it doesn't work properly if 'make' is already an alias|function
function make() {
    # NOTE zsh would output "make is /path/to/make"
    local MAKE_COMMAND=$(type -a -p make | head -1 | sed "s|^make is ||")
    case "$1" in
        --help|--version)
            ${MAKE_COMMAND} "$@"
            return $?
            ;;
        *)
            ;;
    esac
    if [[ -z "${YP_MAKE_COMMAND:-}" ]] && [[ -x make.sh ]]; then
        [[ -f make.sh.successful ]] || {
            echo >&2 "[INFO] Running    ${PWD}/make.sh $*"
            echo >&2 "       instead of ${MAKE_COMMAND} $*"
        }
        YP_MAKE_COMMAND=${MAKE_COMMAND} ./make.sh "$@"
        local EXIT_CODE=$?
        # á la Ubuntu's ~/.sudo_as_admin_successful
        [[ ${EXIT_CODE} -ne 0 ]] || touch make.sh.successful
        return ${EXIT_CODE}
    fi
    ${MAKE_COMMAND} "$@"
}

# for when you want to skip ./make.sh
# NOTE caveat: it doesn't work properly if 'make' is already an alias|function
function make.bak() {
    local MAKE_COMMAND=$(type -a -p make | head -1)
    ${MAKE_COMMAND} "$@"
}
