#!/usr/bin/env bash
#!/usr/bin/env zsh

[[ "${YP_DEV:-}" != "true" ]] || return 0

if [[ -z "${BASH_VERSION:-}" ]] && [[ -z "${ZSH_VERSION:-}" ]]; then
    >&2 echo "$(date +"%H:%M:%S")" "[ERR ] Unsupported shell or \$BASH_VERSION and \$ZSH_VERSION are undefined."
    return 1
fi

[[ -n "${GLOBAL_YP_DIR:-}" ]] || if [[ -n "${BASH_VERSION:-}" ]]; then
    GLOBAL_YP_DIR="$(cd "$(dirname ${BASH_SOURCE[0]})/.." >/dev/null && pwd)"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
    # shellcheck disable=SC2296
    GLOBAL_YP_DIR="$(cd "$(dirname ${(%):-%x})/.." >/dev/null && pwd)"
    autoload -U compaudit compinit bashcompinit
    bashcompinit || {
        >&2 echo "$(date +"%H:%M:%S")" "[ERR ] Initialization of zsh completion features has failed in"
        >&2 echo "$(date +"%H:%M:%S")" "       ${GLOBAL_YP_DIR}/sh/dev.inc.sh."
    }
fi

source "${GLOBAL_YP_DIR}/sh/env.inc.sh" --force
unset YP_DIR

source ${GLOBAL_YP_DIR}/sh/dev-aws-iam-login.inc.sh

# https://github.com/Homebrew/homebrew-command-not-found
HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
[[ ! -f "${HB_CNF_HANDLER}" ]] || source "${HB_CNF_HANDLER}"
unset HB_CNF_HANDLER

yp::path_prepend "${GLOBAL_YP_DIR}/dev/bin"
yp::path_append ./node_modules/.bin

export YP_DEV=true
export YP_DEV_INC_SH=true
