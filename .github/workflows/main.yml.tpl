#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SUPPORT_FIRECLOUD_DIR="$(cd "${GIT_ROOT}/support-firecloud" && pwd)"

SRC_FILE=.github/workflows.src/main.yml

echo "# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (${SRC_FILE})"
cat ${GIT_ROOT}/${SRC_FILE} | \
  ${SUPPORT_FIRECLOUD_DIR}/bin/yaml-expand
