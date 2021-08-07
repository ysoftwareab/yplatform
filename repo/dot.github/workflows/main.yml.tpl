#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SUPPORT_FIRECLOUD_DIR="$(cd "${GIT_ROOT}/support-firecloud" && pwd)"

${GIT_ROOT}/.github/workflows.src/main | \
  ${SUPPORT_FIRECLOUD_DIR}/bin/json2yaml | \
  ${SUPPORT_FIRECLOUD_DIR}/bin/yaml-expand
