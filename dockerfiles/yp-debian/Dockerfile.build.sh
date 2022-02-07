#!/usr/bin/env bash
# -*- mode: sh -*-
set -euo pipefail

YP_DIR=/yplatform
source ${YP_DIR}/dockerfiles/util/common.inc.sh

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

/Dockerfile.test.sh
