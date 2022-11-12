#!/usr/bin/env bash
set -euo pipefail

YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)"

function resolve-include() {
    while IFS= read -r LINE; do
        if echo "${LINE}" | grep -q "^source \${YP_DIR}/"; then
            FILENAME=$(echo "${LINE}" | sed "s|^source \${YP_DIR}/||")
            echo
            echo "# ------------------------------------------------------------------------------"
            echo "# BEGIN ${FILENAME}"
            case "${FILENAME}" in
                'bin/yp-env "$@"')
                    # ignore args
                    cat "${YP_DIR}/bin/yp-env" | resolve-include
                    ;;
                *)
                    cat "${YP_DIR}/${FILENAME}" | resolve-include
                    ;;
            esac
            echo "# END ${FILENAME}"
            echo "# ------------------------------------------------------------------------------"
            echo
        else
            echo "${LINE}"
        fi
    done
}

echo "# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (sh/common.inc.dist.sh.tpl)"
echo "# ------------------------------------------------------------------------------"
echo

cat ${YP_DIR}/sh/common.inc.sh | resolve-include
