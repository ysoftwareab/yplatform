#!/usr/bin/env bash
set -euo pipefail

BREW_WITH_DEFAULT_NAMES=
if [[ "$(uname -s)" = "Darwin" ]]; then
    if [[ "${TRAVIS:-}" = "true" ]]; then
        # speed up by using bottles (no --with-default-names) and changing PATH
        echo "export PATH=$(brew --prefix)/opt/make/gnubin:${PATH}" > ~/.brew_env
    else
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
