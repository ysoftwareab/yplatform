#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null && pwd)"
YP_DIR="$(cd "${GIT_ROOT}/yplatform" >/dev/null && pwd)"

export ENVSUBST_YP_VSN=$(cat ${YP_DIR}/package.json | jq -r ".version")

SRC_FILE_YML=${GIT_ROOT}/.github/workflows.src/$(basename ${BASH_SOURCE[0]} .tpl)
SRC_FILE_EXECUTABLE=${GIT_ROOT}/.github/workflows.src/$(basename ${BASH_SOURCE[0]} .yml.tpl)

if [[ -f "${SRC_FILE_YML}" ]]; then
    echo "# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (${SRC_FILE_YML})"
    cat ${SRC_FILE_YML}
elif [[ -x ${SRC_FILE_EXECUTABLE} ]]; then
    echo "# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (${SRC_FILE_EXECUTABLE})"
    ${SRC_FILE_EXECUTABLE} | ${YP_DIR}/bin/json2yaml
else
    exit 1
fi | \
    envsubst "$(printenv | grep "^ENVSUBST_" | sed "s/=.*//g" | sed "s/^/\${/g" | sed "s/\$/}/g")" | \
    ${YP_DIR}/bin/yaml-expand
