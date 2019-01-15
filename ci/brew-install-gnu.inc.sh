#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing GNU packages..."
BREW_FORMULAE="$(cat <<-EOF
coreutils
diffutils
findutils
gnu-sed
gnu-tar
gnu-time
gnu-which
grep
gzip
unzip
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done

echo_do "brew: Testing GNU packages..."
exe_and_grep_q "find --version | head -1" "^find (GNU findutils) 4\\."
exe_and_grep_q "diff --version | head -1" "^diff (GNU diffutils) 3\\."
exe_and_grep_q "sed --version | head -1" "^sed (GNU sed) 4\\."
exe_and_grep_q "tar --version | head -1" "^tar (GNU tar) 1\\."
exe_and_grep_q "grep --version | head -1" "^grep (GNU grep) 3\\."
exe_and_grep_q "unzip --version 2>&1 | head -2 | tail -1" "^UnZip 6\\."
exe_and_grep_q "unzip --version 2>&1 | head -2 | tail -1" ", by Debian\\."
echo_done
