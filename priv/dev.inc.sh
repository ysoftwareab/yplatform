#!/usr/bin/env sh

if [ -n "${BASH_VERSION}" ]; then
    GLOBAL_SUPPORT_FIRECLOUD_DIR="${GLOBAL_SUPPORT_FIRECLOUD_DIR:-$(dirname ${BASH_SOURCE[0]})/..}"
elif [ -n "${ZSH_VERSION}" ]; then
    GLOBAL_SUPPORT_FIRECLOUD_DIR="${GLOBAL_SUPPORT_FIRECLOUD_DIR:-$(dirname ${(%):-%x})/..}"
    autoload -U compaudit compinit bashcompinit
    bashcompinit || {
        echo >&2 "Initialization of zsh completion features has failed in"
        echo >&2 "${GLOBAL_SUPPORT_FIRECLOUD_DIR}/priv/aws-iam-login.inc.sh."
    }
else
    echo >&2 'Unsupported shell in aws-iam-login.inc.sh, or $BASH_VERSION or $ZSH_VERSION undefined.'
fi

source ${GLOBAL_SUPPORT_FIRECLOUD_DIR}/priv/exe-env.inc.sh
source ${GLOBAL_SUPPORT_FIRECLOUD_DIR}/priv/aws-iam-login.inc.sh
