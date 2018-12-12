#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing basic packages..."
BREW_FORMULAE="$(cat <<-EOF
curl
git
rsync
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done

# test
exe_and_grep_q "curl --version | head -1" "^curl 7\\."
exe_and_grep_q "git --version | head -1" "^git version 2\\."
exe_and_grep_q "rsync --version | head -1" "^rsync  version 3\\."
exe_and_grep_q "wget --version | head -1" "^GNU Wget 1\\."
