#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing common packages..."
source ${YP_DIR}/bootstrap/brew-install-minimal.inc.sh
source ${YP_DIR}/bootstrap/brew-install-docker.inc.sh
echo_done
