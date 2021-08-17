#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing minimal packages..."
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-core.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-asdf.inc.sh
brew_install_one_if nq "cd $(mktemp -d -t firecloud.XXXXXXXXXX) && nq echo 123 | head -1" "^,"
echo_done
