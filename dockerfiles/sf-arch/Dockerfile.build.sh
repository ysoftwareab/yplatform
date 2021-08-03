#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR=/support-firecloud
source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/common.inc.sh

# DEPS
# keep in sync with bootstrap/linux/bootstrap-sudo-arch
[[ -f /support-firecloud.bootstrapped ]] || {
    set -x
    pacman_update

    pacman_install_one ca-certificates
    pacman_install_one gnupg

    pacman_install_one git
    pacman_install_one openssl
    pacman_install_one sudo
    pacman_install_one which

    source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/gitconfig.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/user.inc.sh
}

source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/bootstrap.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/clean.inc.sh
