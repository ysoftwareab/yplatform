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

