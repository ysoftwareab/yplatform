#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR=/support-firecloud
source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/common.inc.sh

# DEPS
# keep in sync with bootstrap/linux/bootstrap-sudo-centos
[[ -f /support-firecloud.bootstrapped ]] || {
    set -x
    yum_update

    yum_install_one ca-certificates
    yum_install_one gnupg

    yum_install_one git
    yum_install_one openssl
    yum_install_one passwd
    yum_install_one sudo
    yum_install_one which

    source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/gitconfig.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/user.inc.sh
}

source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/bootstrap.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/clean.inc.sh
