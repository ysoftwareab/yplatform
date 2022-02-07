#!/usr/bin/env bash
# -*- mode: sh -*-
set -euo pipefail

# keep in sync with dockerfiles/yp-ubuntu-*/Dockerfile.build.sh

YP_DIR=/yplatform
source ${YP_DIR}/dockerfiles/util/common.inc.sh
# shellcheck disable=SC2034
UNAME=codeship
# shellcheck disable=SC2034
GNAME=codeship
# shellcheck disable=SC2034
GIT_USER_EMAIL="bot@codeship.com"
# shellcheck disable=SC2034
GIT_USER_NAME="Codeship"

# DEPS
# keep in sync with bootstrap/bootstrap-sudo-debian
[[ -f /yplatform.bootstrapped ]] || {
    XTRACE_STATE_DOCKERFILE_BUILD_SH="$(set +o | grep xtrace)"
    set -x
    apt_update

    apt_install_one apt-transport-https
    apt_install_one ca-certificates
    apt_install_one software-properties-common
    apt_install_one gnupg-agent

    apt_install_one git
    apt_install_one openssl
    apt_install_one ssh-client
    apt_install_one sudo

    [[ "${YP_SUDO}" != "yp_nosudo_fallback" ]] || export YP_SUDO=sudo

    source ${YP_DIR}/dockerfiles/util/root.inc.sh
    source ${YP_DIR}/dockerfiles/util/user.inc.sh
    eval "${XTRACE_STATE_DOCKERFILE_BUILD_SH}"
    unset XTRACE_STATE_DOCKERFILE_BUILD_SH
}

source ${YP_DIR}/dockerfiles/util/bootstrap.inc.sh
source ${YP_DIR}/dockerfiles/util/clean.inc.sh

# /Dockerfile.test.sh
sudo --preserve-env --set-home --user root ${BASH} -l -i -c "/Dockerfile.test.sh root"
sudo --preserve-env --set-home --user ${UNAME} ${BASH} -l -i -c "/Dockerfile.test.sh ${UNAME}"
