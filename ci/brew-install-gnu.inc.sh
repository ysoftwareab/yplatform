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

# test
exe_and_grep_q "find --version | head -1" "^find (GNU findutils) 4\\."
exe_and_grep_q "diff --version | head -1" "^diff (GNU diffutils) 3\\."
exe_and_grep_q "sed --version | head -1" "^sed (GNU sed) 4\\."
exe_and_grep_q "tar --version | head -1" "^tar (GNU tar) 1\\."
exe_and_grep_q "grep --version | head -1" "^grep (GNU grep) 3\\."
exe_and_grep_q "unzip --version 2>&1 | head -2 | tail -1" "^UnZip 6\\."
exe_and_grep_q "unzip --version 2>&1 | head -2 | tail -1" ", by Debian\\."
