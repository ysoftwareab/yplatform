#!/usr/bin/env bash
set -euo pipefail

# package managers first
source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/magic.inc.sh
if command -v apt-get >/dev/null 2>&1; then
    source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/apt.inc.sh
elif command -v yum >/dev/null 2>&1; then
    source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/yum.inc.sh
elif command -v pacman >/dev/null 2>&1; then
    source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/pacman.inc.sh
elif command -v apk >/dev/null 2>&1; then
    source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/apk.inc.sh
fi

source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/env.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/lockfile.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/install.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/print.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util/update.inc.sh
