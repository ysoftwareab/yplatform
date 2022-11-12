#!/usr/bin/env bash
set -euo pipefail

CORE_INC_MK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

function resolve-include() {
    while IFS= read -r LINE; do
        if echo "${LINE}" | grep -q "^include \$(CORE_INC_MK_DIR)/"; then
            FILENAME=$(echo "${LINE}" | sed "s|^include \$(CORE_INC_MK_DIR)/||")
            echo
            echo "# ------------------------------------------------------------------------------"
            echo "# ${LINE}"
            echo "# BEGIN ${FILENAME}"
            cat "${CORE_INC_MK_DIR}/${FILENAME}" | resolve-include
            echo "# END ${FILENAME}"
            echo "# ------------------------------------------------------------------------------"
            echo
        else
            echo "${LINE}"
        fi
    done
}

echo "# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (mk/common.inc.dist.mk.tpl)"
echo "# ------------------------------------------------------------------------------"
echo

cat "${CORE_INC_MK_DIR}/common.inc.mk" | resolve-include
