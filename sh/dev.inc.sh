#!/usr/bin/env bash

[[ "${YP_DEV:-}" != "true" ]] || return 0

if [[ -n "${BASH_VERSION:-}" ]]; then
    GLOBAL_YP_DIR="${GLOBAL_YP_DIR:-$(dirname ${BASH_SOURCE[0]})/..}"
    GLOBAL_YP_DIR="$(cd "${GLOBAL_YP_DIR}" >/dev/null && pwd)"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
    # shellcheck disable=SC2296
    GLOBAL_YP_DIR="${GLOBAL_YP_DIR:-$(dirname ${(%):-%x})/..}"
    GLOBAL_YP_DIR="$(cd "${GLOBAL_YP_DIR}" >/dev/null && pwd)"
    autoload -U compaudit compinit bashcompinit
    bashcompinit || {
        >&2 echo "$(date +"%H:%M:%S")" "[ERR ] Initialization of zsh completion features has failed in"
        >&2 echo "$(date +"%H:%M:%S")" "       ${GLOBAL_YP_DIR}/sh/dev.inc.sh."
    }
else
    >&2 echo "$(date +"%H:%M:%S")" "[ERR ] Unsupported shell or \$BASH_VERSION and \$ZSH_VERSION are undefined."
    return 1
fi

unset YP_ENV # force bin/yp-env
# shellcheck disable=SC1091
source "${GLOBAL_YP_DIR}/sh/env.inc.sh"
unset YP_DIR

# shellcheck disable=SC1091
source "${GLOBAL_YP_DIR}/sh/dev-aws-iam-login.inc.sh"

# https://github.com/Homebrew/homebrew-command-not-found
HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
[[ ! -f "${HB_CNF_HANDLER}" ]] || source "${HB_CNF_HANDLER}"
unset HB_CNF_HANDLER

yp::path_prepend ${GLOBAL_YP_DIR}/dev/bin
yp::path_append ./node_modules/.bin

export YP_DEV=true
