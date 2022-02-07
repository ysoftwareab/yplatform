#!/usr/bin/env bash
set -euo pipefail

# USAGE:
# - declare YP_DLX_ARGS
# - declare 'main' function
# - source pnpm-dlx.inc.sh
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
    [[ -z "${VERBOSE}" ]] || YP_DLX_ARGS="${YP_DLX_ARGS} --loglevel=verbose"

    # npm@6 and npm@7 are not compatible regarding the --yes flag
    # see https://github.com/npm/cli/issues/2226#issuecomment-732475247
    export npm_config_yes=true

    # NOTE 'pnpm dlx /absolute/path/to/executable' means run 'node /absolute/path/to/executable'
    # while 'PATH=/absolute/path/to/:$PATH pnpm dlx executable' means run 'executable'
    # so that's why we mangle $PATH...
    export PATH="${PATH}:${MYSELF_CMD_DIR}"
    hash -r
    YP_DLX_CMD_ARGS=("$@")
    eval "${VAR_PASS}=1 ${VAR_ARGS_FD}=<(declare -p YP_DLX_CMD_ARGS) \
        pnpm ${YP_DLX_ARGS} dlx ${MYSELF_CMD_BASENAME}"
    exit 0
fi

source "${!VAR_ARGS_FD}"

# make DLX node_modules available to node
DLX_PATH=$(echo ${PATH} | tr ":" "\n" | grep "/dlx-" | head -n1 || true)
DLX_PATH=$(dirname ${DLX_PATH})
DLX_PATH=${DLX_PATH}/lib/node_modules
export NODE_PATH=${DLX_PATH}:${NODE_PATH:-}
# NOTE for security reasons, system executables should NOT be overriden
# export PATH=${DLX_PATH}/.bin:${PATH:-}
# export PATH=${PATH:-}:${DLX_PATH}/.bin
# hash -r

main "${YP_DLX_CMD_ARGS[@]}"
