#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing common packages..."
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-minimal.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-gnu.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-basic.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-node.inc.sh
echo_done
