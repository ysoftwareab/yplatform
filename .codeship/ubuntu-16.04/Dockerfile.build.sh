#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR=/support-firecloud
source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/env.inc.sh
# shellcheck disable=SC2034
UNAME=codeship
# shellcheck disable=SC2034
GNAME=codeship
# shellcheck disable=SC2034
GIT_USER_EMAIL="bot@codeship.com"
# shellcheck disable=SC2034
GIT_USER_NAME="Codeship"

# DEPS
source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/exe.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/apt.inc.sh
[[ -f /support-firecloud.bootstrapped ]] || {
    apt_update

    apt_install_one apt-transport-https
    apt_install_one ca-certificates
    apt_install_one software-properties-common
    apt_install_one gnupg-agent

    apt_install_one git
    apt_install_one openssl
    apt_install_one ssh-client
    apt_install_one sudo

    source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/gitconfig.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/user.inc.sh
}

# source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/bootstrap.inc.sh
# source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/clean.inc.sh
