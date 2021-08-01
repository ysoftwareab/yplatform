#!/usr/bin/env bash
set -euo pipefail

# package managers first
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/apk.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/apt.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/magic.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/pacman.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/yum.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/env.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/lockfile.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/install.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/print.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/update.inc.sh
