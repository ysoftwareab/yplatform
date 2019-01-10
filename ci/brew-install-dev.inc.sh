#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing dev packages..."
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-common.inc.sh
echo_done
