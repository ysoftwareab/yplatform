#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing core packages..."
else
    echo_do "brew: Installing core packages..."
    brew_install_one_if ${SUPPORT_FIRECLOUD_DIR}/Formula/editorconfig-checker.rb \
        "editorconfig-checker --version | head -1" "^2\."
    brew_install_one_if ${SUPPORT_FIRECLOUD_DIR}/Formula/retry.rb \
        "retry --help | head -1" "^Usage: retry"
    brew_install_one_if curl "curl --version | head -1" "^curl 7\."
    brew_install_one_if git "git --version | head -1" "^git version 2\."
    brew_install_one_if jq "jq --version | head -1" "^jq-1\."
    # installing perl for performance reasons, since it takes a very long time to install via homebrew,
    # and quite a few formulas require it
    # NOTE: many formulas are optimized to use system's perl on Darwin, but not Linux
    brew_install_one_if perl "perl --version 2>&1 | head -2 | tail -1" "^This is perl 5,"
    brew_install_one_if shellcheck "shellcheck --version | head -2 | tail -1" "^version: 0\.7\."
    brew_install_one_if unzip "unzip --version 2>&1 | head -2 | tail -1" "^UnZip 6\."
    brew_install_one_if unzip "unzip --version 2>&1 | head -2 | tail -1" ", by Debian\."
    brew_install_one_if zip "zip --version 2>&1 | head -2 | tail -1" "Zip 3\.0"
    brew_install_one_if zip "zip --version 2>&1 | head -2 | tail -1" ", by Info-ZIP\."

    source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-gnu.inc.sh

    echo_done
fi
