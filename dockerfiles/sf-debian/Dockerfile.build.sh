#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR=/support-firecloud
source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/common.inc.sh

# DEPS
# keep in sync with bootstrap/linux/bootstrap-sudo-debian
[[ -f /support-firecloud.bootstrapped ]] || {
    XTRACE_STATE_DOCKERFILE_BUILD_SH="$(set +o | grep xtrace)"
    set -x
    cat <<EOF > /etc/apt/apt.conf.d/sf
Dpkg::Options {
    "--force-confdef";
    "--force-confold";
}
EOF
    apt_update

    apt_install_one apt-transport-https
    apt_install_one ca-certificates
    apt_install_one software-properties-common
    apt_install_one gnupg-agent

    apt_install_one git
    apt_install_one openssl
    apt_install_one ssh-client
    apt_install_one sudo

    [[ "${SF_SUDO}" = "sf_nosudo_fallback" ]] || export SF_SUDO=sudo

    source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/gitconfig.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/user.inc.sh
    eval "${XTRACE_STATE_DOCKERFILE_BUILD_SH}"
    unset XTRACE_STATE_DOCKERFILE_BUILD_SH
}

source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/bootstrap.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/clean.inc.sh
