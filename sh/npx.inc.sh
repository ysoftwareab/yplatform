#!/usr/bin/env bash
set -euo pipefail

# USAGE:
# - declare YP_NPX_ARGS
# - declare 'main' function
# - source npx.inc.sh
# - main will be called with the same positional args as the caller
#
# examples: bin/node-esm bin/yaml-expand

MYSELF_CMD=$0
[[ "${MYSELF_CMD:0:1}" = "/" ]] || \
    MYSELF_CMD="$(cd $(dirname "${PWD}/${MYSELF_CMD}") >/dev/null && pwd)/$(basename ${MYSELF_CMD})"

MYSELF_CMD_BASENAME="$(basename ${MYSELF_CMD})"
MYSELF_CMD_DIR="$(cd "$(dirname "${MYSELF_CMD}")" >/dev/null && pwd)"
VAR_PREFIX="$(echo "${MYSELF_CMD_BASENAME}" | tr "[:lower:]" "[:upper:]" | sed "s/[^A-Z0-9]\{1,\}/_/g" | sed "s/^_//" | sed "s/_$//")" # editorconfig-checker-disable-line
VAR_PASS="${VAR_PREFIX}_PASS"
VAR_ARGS_FD="${VAR_PREFIX}_ARGS_FD"

# if first call, install esm and call script again
if [[ -z "${!VAR_PASS:-}" ]]; then
    V="${V:-${VERBOSE:-}}"
    VERBOSE="${V}"
    [[ "${VERBOSE}" != "1" ]] || VERBOSE=true
    # npm_config_loglevel doesn't seem to work for npx ?!
    # [[ -z "${VERBOSE}" ]] || export npm_config_loglevel=verbose
    [[ -z "${VERBOSE}" ]] || YP_NPX_ARGS="${YP_NPX_ARGS} --loglevel=verbose"

    # npm@6 and npm@7 are not compatible regarding the --yes flag
    # see https://github.com/npm/cli/issues/2226#issuecomment-732475247
    export npm_config_yes=true

    # NOTE 'npx /absolute/path/to/executable' means run 'node /absolute/path/to/executable'
    # while 'PATH=/absolute/path/to/:$PATH npx executable' means run 'executable'
    # so that's why we mangle $PATH...
    export PATH="${PATH}:${MYSELF_CMD_DIR}"
    hash -r
    YP_NPX_CMD_ARGS=("$@")
    export ${VAR_PASS}=1
    export ${VAR_ARGS_FD}=$(mktemp -u -t ${VAR_ARGS_FD}.XXXXXXXXXX)
    mkfifo ${!VAR_ARGS_FD}
    >${!VAR_ARGS_FD} declare -p YP_NPX_CMD_ARGS &
    npx ${YP_NPX_ARGS} ${MYSELF_CMD_BASENAME} || {
        rm -f ${!VAR_ARGS_FD}
        exit 1
    }
    exit 0
fi

source "${!VAR_ARGS_FD}"

# make NPX node_modules available to node
NPX_PATH=$(echo ${PATH} | tr ":" "\n" | grep "\.npm/_npx" | head -n1 || true)
# starting NPM@7 the local packages will be reused, thus NPX_PATH is empty
[[ -z "${NPX_PATH}" ]] || {
    NPX_PATH=$(dirname ${NPX_PATH})
    # npx in npm versions pre-v7 used a lib/node_modules subdir
    [[ ! -d "${NPX_PATH}/lib/node_modules" ]] || NPX_PATH=${NPX_PATH}/lib/node_modules
    export NODE_PATH=${NPX_PATH}:${NODE_PATH:-}
    # NOTE for security reasons, system executables should NOT be overriden
    # export PATH=${NPX_PATH}/.bin:${PATH:-}
    export PATH=${PATH:-}:${NPX_PATH}/.bin
    hash -r
}

main "${YP_NPX_CMD_ARGS[@]}"
