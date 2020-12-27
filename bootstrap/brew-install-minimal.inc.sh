#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing minimal packages..."
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-core.inc.sh
echo_done
