#!/usr/bin/env bash

[[ "${YP_DEV_INC_SH:-}" = "true" ]] || {
    if [[ -n "${BASH_VERSION:-}" ]]; then
        GLOBAL_YP_DIR="${GLOBAL_YP_DIR:-$(dirname ${BASH_SOURCE[0]})/..}"
        GLOBAL_YP_DIR="$(cd "${GLOBAL_YP_DIR}" >/dev/null && pwd)"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        # shellcheck disable=SC2296
        GLOBAL_YP_DIR="${GLOBAL_YP_DIR:-$(dirname ${(%):-%x})/..}"
        GLOBAL_YP_DIR="$(cd "${GLOBAL_YP_DIR}" >/dev/null && pwd)"
        autoload -U compaudit compinit bashcompinit
        bashcompinit || {
            echo >&2 "Initialization of zsh completion features has failed in"
            echo >&2 "${GLOBAL_YP_DIR}/sh/dev.inc.sh."
        }
    else
        echo >&2 "Unsupported shell or \$BASH_VERSION and \$ZSH_VERSION are undefined."
    fi

    source ${GLOBAL_YP_DIR}/sh/env.inc.sh
    source ${GLOBAL_YP_DIR}/sh/dev-aws-iam-login.inc.sh

    yp::path_prepend ${GLOBAL_YP_DIR}/dev/bin
    yp::path_append ./node_modules/.bin

    export YP_DEV_INC_SH=true
    unset YP_DIR
}
