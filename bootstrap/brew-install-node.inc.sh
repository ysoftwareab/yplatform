#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing NodeJS packages..."
else
    echo_do "brew: Installing NodeJS packages..."
    brew_install_one node

    # allow npm upgrade to fail on WSL; fails with EACCESS
    npm install --global --force npm@6 || ${SUPPORT_FIRECLOUD_DIR}/bin/is-wsl
    npm install --global json@9
    hash -r
    echo_done

    echo_do "brew: Testing NodeJS packages..."
    exe_and_grep_q "node --version | head -1" "^v"
    exe_and_grep_q "npm --version | head -1" "^6\."
    exe_and_grep_q "json --version | head -1" "^json 9\."
    echo_done
fi
