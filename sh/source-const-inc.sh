#!/usr/bin/env bash
set -euo pipefail

# CONST.inc{,.secret} env
# set -a
# shellcheck disable=SC1091
[[ ! -f ${GIT_ROOT}/CONST.inc ]] || source ${GIT_ROOT}/CONST.inc
if git config --local transcrypt.version >/dev/null; then
    # shellcheck disable=SC1091
    [[ ! -f ${GIT_ROOT}/CONST.inc.secret ]] || source ${GIT_ROOT}/CONST.inc.secret
fi
# set +a
