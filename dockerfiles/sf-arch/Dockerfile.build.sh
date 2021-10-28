#!/usr/bin/env bash
set -euo pipefail

YP_DIR=/yplatform
source ${YP_DIR}/dockerfiles/util/common.inc.sh

# DEPS
# keep in sync with bootstrap/linux/bootstrap-sudo-arch
[[ -f /yplatform.bootstrapped ]] || {
    XTRACE_STATE_DOCKERFILE_BUILD_SH="$(set +o | grep xtrace)"
    set -x
    pacman_update

    pacman_install_one ca-certificates
    pacman_install_one gnupg

    pacman_install_one git
    pacman_install_one openssl
    pacman_install_one sudo
    pacman_install_one which

    [[ "${YP_SUDO}" = "yp_nosudo_fallback" ]] || export YP_SUDO=sudo

    source ${YP_DIR}/dockerfiles/util/gitconfig.inc.sh
    source ${YP_DIR}/dockerfiles/util/user.inc.sh
    eval "${XTRACE_STATE_DOCKERFILE_BUILD_SH}"
    unset XTRACE_STATE_DOCKERFILE_BUILD_SH
}

source ${YP_DIR}/dockerfiles/util/bootstrap.inc.sh
source ${YP_DIR}/dockerfiles/util/clean.inc.sh
