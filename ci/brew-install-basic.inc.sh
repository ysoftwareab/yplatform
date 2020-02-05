#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing basic packages..."
else
    echo_do "brew: Installing basic packages..."

    BREW_FORMULAE="$(cat <<-EOF
${SUPPORT_FIRECLOUD_DIR}/ci/retry.rb
curl
git
rsync
unzip
zip
EOF
)"
    brew_install "${BREW_FORMULAE}"
    unset BREW_FORMULAE
    echo_done

    echo_do "brew: Testing basic packages..."
    exe_and_grep_q "curl --version | head -1" "^curl 7\\."
    exe_and_grep_q "git --version | head -1" "^git version 2\\."
    exe_and_grep_q "rsync --version | head -1" "^rsync  version 3\\."
    exe_and_grep_q "unzip --version 2>&1 | head -2 | tail -1" "^UnZip 6\\."
    exe_and_grep_q "unzip --version 2>&1 | head -2 | tail -1" ", by Debian\\."
    exe_and_grep_q "zip --version 2>&1 | head -2 | tail -1" "Zip 3\\.0"
    exe_and_grep_q "zip --version 2>&1 | head -2 | tail -1" ", by Info-ZIP\\."
    echo_done
fi
