#!/usr/bin/env bash

if [ -n "${BASH_VERSION:-}" ]; then
    GLOBAL_SUPPORT_FIRECLOUD_DIR="${GLOBAL_SUPPORT_FIRECLOUD_DIR:-$(dirname ${BASH_SOURCE[0]})/..}"
elif [ -n "${ZSH_VERSION:-}" ]; then
    GLOBAL_SUPPORT_FIRECLOUD_DIR="${GLOBAL_SUPPORT_FIRECLOUD_DIR:-$(dirname ${(%):-%x})/..}"
    autoload -U compaudit compinit bashcompinit
    bashcompinit || {
        echo >&2 "Initialization of zsh completion features has failed in"
        echo >&2 "${GLOBAL_SUPPORT_FIRECLOUD_DIR}/sh/dev.inc.sh."
    }
else
    echo >&2 "Unsupported shell or \$BASH_VERSION and \$ZSH_VERSION are undefined."
fi

SUPPORT_FIRECLOUD_DIR=${GLOBAL_SUPPORT_FIRECLOUD_DIR} source ${GLOBAL_SUPPORT_FIRECLOUD_DIR}/sh/exe-env.inc.sh
SUPPORT_FIRECLOUD_DIR=${GLOBAL_SUPPORT_FIRECLOUD_DIR} source ${GLOBAL_SUPPORT_FIRECLOUD_DIR}/sh/aws-iam-login.inc.sh

sf_path_prepend ${GLOBAL_SUPPORT_FIRECLOUD_DIR}/dev/bin
sf_path_append ./node_modules/.bin

export SF_DEV_INC_SH=true
