#!/usr/bin/env bash
# -*- mode: sh -*-
set -euo pipefail

YP_DIR=/yplatform
source ${YP_DIR}/dockerfiles/util/common.inc.sh

# DEPS
# keep in sync with bootstrap/bootstrap-sudo-rhel
[[ -f /yplatform.bootstrapped ]] || {
    XTRACE_STATE_DOCKERFILE_BUILD_SH="$(set +o | grep xtrace)"
    set -x
    yum_update

    yum_install_one ca-certificates
    yum_install_one gnupg

    yum_install_one git
    yum_install_one openssl
    yum_install_one passwd
    yum_install_one sudo
    yum_install_one which

    [[ "${YP_SUDO}" != "yp_nosudo_fallback" ]] || export YP_SUDO=sudo

    source ${YP_DIR}/dockerfiles/util/root.inc.sh
    source ${YP_DIR}/dockerfiles/util/user.inc.sh
    eval "${XTRACE_STATE_DOCKERFILE_BUILD_SH}"
    unset XTRACE_STATE_DOCKERFILE_BUILD_SH
}

source ${YP_DIR}/dockerfiles/util/bootstrap.inc.sh
source ${YP_DIR}/dockerfiles/util/clean.inc.sh

/Dockerfile.test.sh
