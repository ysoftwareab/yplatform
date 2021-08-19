#!/usr/bin/env bash

# when not in CI, use dev install
[[ "${CI:-}" = "true" ]] || SF_CI_BREW_INSTALL=${SF_CI_BREW_INSTALL:-dev}

source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-${SF_CI_BREW_INSTALL}.inc.sh

# SF_DOCKER declared in dockerfiles/*/Dockerfile.build.sh
[[ "${SF_DOCKER:-}" != "true" ]] || {
    [[ "${SF_CI_BREW_INSTALL}" = "minimal" ]] || { \
        # installing perl for performance reasons,
        # since it takes a very long time to install via homebrew on Linux
        # NOTE: many formulas are optimized to use system's perl on Darwin, but not Linux
        [[ "${OS_RELEASE_ID}" != "alpine" ]] || brew_install_one gcc
        brew_install_one perl
    }
}
