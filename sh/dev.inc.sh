#!/usr/bin/env sh

if [ -n "${BASH_VERSION}" ]; then
    GLOBAL_SUPPORT_FIRECLOUD_DIR="${GLOBAL_SUPPORT_FIRECLOUD_DIR:-$(dirname ${BASH_SOURCE[0]})/..}"
elif [ -n "${ZSH_VERSION}" ]; then
    GLOBAL_SUPPORT_FIRECLOUD_DIR="${GLOBAL_SUPPORT_FIRECLOUD_DIR:-$(dirname ${(%):-%x})/..}"
    autoload -U compaudit compinit bashcompinit
    bashcompinit || {
        echo >&2 "Initialization of zsh completion features has failed in"
        echo >&2 "${GLOBAL_SUPPORT_FIRECLOUD_DIR}/sh/aws-iam-login.inc.sh."
    }
else
    echo >&2 "Unsupported shell in aws-iam-login.inc.sh, or \$BASH_VERSION or \$ZSH_VERSION undefined."
fi

source ${GLOBAL_SUPPORT_FIRECLOUD_DIR}/sh/exe-env.inc.sh
source ${GLOBAL_SUPPORT_FIRECLOUD_DIR}/sh/aws-iam-login.inc.sh

function sf-bin() {
    local GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
    local SF_BIN=$1
    shift 1
    if [[ -x ${GIT_ROOT}/support-firecloud/bin/${SF_BIN} ]]; then
        ${GIT_ROOT}/support-firecloud/bin/${SF_BIN} "$@"
        return 0
    fi
    ${GLOBAL_SUPPORT_FIRECLOUD_DIR}/bin/${SF_BIN} "$@"
}

alias sake="sf-bin sake"
# alias node-esm="sf-bin node-esm"
ln -sf ${GLOBAL_SUPPORT_FIRECLOUD_DIR}/bin/node-esm /usr/local/bin/node-esm

export SF_DEV_INC_SH=true
