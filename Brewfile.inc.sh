#!/usr/bin/env bash

# when not in CI, use dev install
[[ "${CI:-}" = "true" ]] || SF_CI_BREW_INSTALL=${SF_CI_BREW_INSTALL:-dev}

source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-${SF_CI_BREW_INSTALL}.inc.sh

[[ "${SF_CI_BREW_INSTALL}" != "minimal" ]] || \
    source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-node.inc.sh

# SF_DOCKER declared in dockerfiles/*/Dockerfile.build.sh
[[ "${SF_DOCKER:-}" != "true" ]] || {
    # installing perl for performance reasons,
    # since it takes a very long time to install via homebrew on Linux
    # NOTE: many formulas are optimized to use system's perl on Darwin, but not Linux
    # brew_install_one perl
    brew_install_one_if perl "perl --version 2>&1 | head -2 | tail -1" "^This is perl 5,"

    # installing autoconf/automake for performance reasons,
    # since it takes a very long time to install via homebrew on Linux
    # NOTE autoconf/automake depends on perl on Linux
    brew_install_one_if autoconf "autoconf --version | head -1" "^autoconf (GNU Autoconf) 2\."
    brew_install_one_if automake "automake --version | head -1" "^automake (GNU automake) 1\."
}
