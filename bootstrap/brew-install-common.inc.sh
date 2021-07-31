#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing common packages..."
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-minimal.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-git-diff.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-node.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-docker.inc.sh
echo_done
