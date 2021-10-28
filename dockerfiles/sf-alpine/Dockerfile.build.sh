#!/usr/bin/env bash
set -euo pipefail

YP_DIR=/yplatform
source ${YP_DIR}/dockerfiles/util/common.inc.sh

# DEPS
# keep in sync with bootstrap/linux/bootstrap-sudo-alpine
[[ -f /yplatform.bootstrapped ]] || {
    XTRACE_STATE_DOCKERFILE_BUILD_SH="$(set +o | grep xtrace)"
    set -x
    apk_update

    apk_install_one ca-certificates
    apk_install_one gnupg

    apk_install_one git
    apk_install_one openssl
    apk_install_one openssh-client
    apk_install_one sudo

    [[ "${YP_SUDO}" = "sf_nosudo_fallback" ]] || export YP_SUDO=sudo

    source ${YP_DIR}/dockerfiles/util/gitconfig.inc.sh
    source ${YP_DIR}/dockerfiles/util/user.inc.sh
    eval "${XTRACE_STATE_DOCKERFILE_BUILD_SH}"
    unset XTRACE_STATE_DOCKERFILE_BUILD_SH
}

source ${YP_DIR}/dockerfiles/util/bootstrap.inc.sh
source ${YP_DIR}/dockerfiles/util/clean.inc.sh
