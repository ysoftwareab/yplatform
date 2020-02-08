#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing core packages..."
else
    echo_do "brew: Installing core packages..."
    # 'findutils' provides 'xargs', because the OSX version has no 'xargs -r'
    BREW_FORMULAE="$(cat <<-EOF
bash
findutils
jq
make
EOF
)"
    brew_install "${BREW_FORMULAE}"
    unset BREW_FORMULAE
    echo_done

    echo_do "brew: Testing core packages..."
    exe_and_grep_q "bash --version | head -1" "^GNU bash, version [^123]\\."
    exe_and_grep_q "jq --version | head -1" "^jq\\-1\\."
    exe_and_grep_q "make --version | head -1" "^GNU Make 4\\."
    exe_and_grep_q "xargs --help" "no-run-if-empty"
    echo_done
fi
