#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing common packages..."
else
    echo_do "brew: Installing common packages..."
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-minimal.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-node.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-docker.inc.sh
    # installing perl for performance reasons, since it takes a very long time to install via homebrew,
    # and quite a few formulas require it
    # NOTE: many formulas are optimized to use system's perl on Darwin, but not Linux
    brew_install perl
    echo_done
fi
