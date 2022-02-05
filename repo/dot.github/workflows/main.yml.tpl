#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null && pwd)"
YP_DIR="$(cd "${GIT_ROOT}/yplatform" >/dev/null && pwd)"

${GIT_ROOT}/.github/workflows.src/$(basename ${BASH_SOURCE[0]} .yml.tpl) | \
  ${YP_DIR}/bin/json2yaml | \
  ${YP_DIR}/bin/yaml-expand
