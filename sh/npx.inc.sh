#!/usr/bin/env bash

# USAGE:
# - declare NPX_ARGS
# - declare 'main' function
# - source npx.inc.sh
#
# examples: bin/ndoe-esm bin/yaml-expand

MYSELF_CMD=$0
[[ "${MYSELF_CMD:0:1}" = "/" ]] || MYSELF_CMD="$(cd $(dirname "${PWD}/${MYSELF_CMD}") && pwd)/$(basename ${MYSELF_CMD})"

MYSELF_CMD_BASENAME="$(basename ${MYSELF_CMD})"
MYSELF_CMD_DIR="$(cd "$(dirname "${MYSELF_CMD}")" && pwd)"
VAR_PREFIX="$(echo "${MYSELF_CMD_BASENAME}" | tr "[:lower:]" "[:upper:]" | sed "s/[^A-Z0-9]\{1,\}/_/g" | sed "s/^_//" | sed "s/_$//")" # editorconfig-checker-disable-line
VAR_PASS="${VAR_PREFIX}_PASS"
VAR_ARGS="${VAR_PREFIX}_ARGS"


# if first call, install esm and call script again
if [[ -z "${!VAR_PASS:-}" ]]; then
    # npm@6 and npm@7 are not compatible regarding the --yes flag
    # see https://github.com/npm/cli/issues/2226#issuecomment-732475247
    export npm_config_yes=true

    eval "export ${VAR_PASS}=1"
    eval "export ${VAR_ARGS}=\"$*\""
    export PATH="${PATH}:${MYSELF_CMD_DIR}"
    npx ${NPX_ARGS} ${MYSELF_CMD_BASENAME}
    exit 0
fi

# make NPX node_modules available to node
NPX_PATH=$(echo ${PATH} | tr ":" "\n" | grep "\.npm/_npx" | head -n1 || true)
# starting NPM@7 the local packages will be reused, thus NPX_PATH is empty
[[ -z "${NPX_PATH}" ]] || {
    NPX_PATH=$(dirname ${NPX_PATH})
    export NODE_PATH=${NPX_PATH}/lib/node_modules:${NPX_PATH}:${NODE_PATH:-}
}

main
