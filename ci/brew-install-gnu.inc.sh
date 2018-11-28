#!/usr/bin/env bash
set -euo pipefail

BREW_WITH_DEFAULT_NAMES=
if [[ "$(uname -s)" = "Darwin" ]]; then
    if [[ "${TRAVIS:-}" != "true" ]]; then
        BREW_WITH_DEFAULT_NAMES="--with-default-names"
    fi
fi

echo_do "brew: Installing GNU packages..."
BREW_FORMULAE="$(cat <<-EOF
coreutils
diffutils
findutils ${BREW_WITH_DEFAULT_NAMES}
gnu-sed ${BREW_WITH_DEFAULT_NAMES}
gnu-tar ${BREW_WITH_DEFAULT_NAMES}
gnu-time ${BREW_WITH_DEFAULT_NAMES}
gnu-which ${BREW_WITH_DEFAULT_NAMES}
grep ${BREW_WITH_DEFAULT_NAMES}
gzip
unzip
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE BREW_WITH_DEFAULT_NAMES
echo_done
