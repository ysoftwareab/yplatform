#!/usr/bin/env bash
set -euo pipefail

[[ -n ${INSTALL_SUPPORT_FIRECLOUD_SH:-} ]] || {
    export SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    source ${SUPPORT_FIRECLOUD_DIR}/sh/core.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/sh/exe.inc.sh

    # export INSTALL_SUPPORT_FIRECLOUD_SH=true
}
