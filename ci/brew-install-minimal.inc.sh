#!/usr/bin/env bash
set -euo pipefail

BREW_WITH_DEFAULT_NAMES=
if [[ "$(uname -s)" = "Darwin" ]]; then
    if [[ "${TRAVIS:-}" != "true" ]]; then
        BREW_WITH_DEFAULT_NAMES="--with-default-names"
    fi
fi

echo_do "brew: Installing minimal packages..."
BREW_FORMULAE="$(cat <<-EOF
bash
jq
make ${BREW_WITH_DEFAULT_NAMES}
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE BREW_WITH_DEFAULT_NAMES
echo_done

# test
exe_and_grep_q "bash --version | head -1" "^GNU bash, version 4\\."
exe_and_grep_q "jq --version | head -1" "^jq\\-1\\."
exe_and_grep_q "make --version | head -1" "^GNU Make 4\\."
