#!/usr/bin/env bash
set -euo pipefail

YP_DIR=/yplatform
source ${YP_DIR}/dockerfiles/util/common.inc.sh

# DEPS
# keep in sync with bootstrap/linux/bootstrap-sudo-debian
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

    [[ "${ARCH_NORMALIZED}" != "arm64" ]] || {
        echo_do "Installing Ruby@2.6 for Hombrew on Linux (arm64)..."
        # https://docs.brew.sh/Homebrew-on-Linux#arm
        # https://github.com/Homebrew/brew/issues/11320
        # https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
        apt_install_one autoconf
        apt_install_one bison
        apt_install_one build-essential
        apt_install_one libssl-dev
        apt_install_one libyaml-dev
        apt_install_one libreadline6-dev
        apt_install_one zlib1g-dev
        apt_install_one libncurses5-dev
        apt_install_one libffi-dev
        apt_install_one libgdbm6
        apt_install_one libgdbm-dev
        apt_install_one libdb-dev

        apt_install_one curl
        git clone https://github.com/rbenv/ruby-build.git /opt/ruby-build
        PREFIX=/usr/local /opt/ruby-build/install.sh
        ruby-build $(ruby-build --list | grep "^2\.6\." | head -n1) /usr
        echo_done
    }

    [[ "${YP_SUDO}" = "yp_nosudo_fallback" ]] || export YP_SUDO=sudo

    source ${YP_DIR}/dockerfiles/util/gitconfig.inc.sh
    source ${YP_DIR}/dockerfiles/util/user.inc.sh
    eval "${XTRACE_STATE_DOCKERFILE_BUILD_SH}"
    unset XTRACE_STATE_DOCKERFILE_BUILD_SH
}

source ${YP_DIR}/dockerfiles/util/bootstrap.inc.sh
source ${YP_DIR}/dockerfiles/util/clean.inc.sh
