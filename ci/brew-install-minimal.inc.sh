#!/usr/bin/env bash
set -euo pipefail

function brew_install_perl() {
    # workaround for failing to install `perl` (pyenv > autoconf > perl)
    # fatal error: xlocale.h: No such file or directory
    # see https://github.com/Homebrew/linuxbrew-core/issues/20914
    if [[ "${OS_SHORT}" = "linux" ]] && [[ ! -f /usr/include/xlocale.h ]]; then
        ${SUDO} ln -s /usr/include/locale.h /usr/include/xlocale.h
    fi

    brew_install perl
}

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing minimal packages..."
else
    echo_do "brew: Installing minimal packages..."
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-core.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-gnu.inc.sh

    # installing perl for performance reasons, since it takes a very long time to install via homebrew,
    # and quite a few formulas require it
    # NOTE: many formulas are optimized to use system's perl on Darwin, but not Linux
    brew_install_perl

    echo_done
fi
