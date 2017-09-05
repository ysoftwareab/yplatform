#!/usr/bin/env bash
set -euo pipefail

[ -n "${INSTALL_SUPPORT_FIRECLOUD_SH:-}" ] || {
    export SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    export SUPPORT_FIRECLOUD_CACHE_DIR=/tmp/support-firecloud.cache
    mkdir -p "${SUPPORT_FIRECLOUD_CACHE_DIR}"

    source ${SUPPORT_FIRECLOUD_DIR}/bin/core.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/bin/exe.inc.sh

    # export INSTALL_SUPPORT_FIRECLOUD_SH=true
}
