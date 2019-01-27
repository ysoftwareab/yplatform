#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing CI packages..."
BREW_FORMULAE="$(cat <<-EOF
git
rsync
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done

echo_do "brew: Testing minimal packages..."
exe_and_grep_q "git --version | head -1" "^git version 2\\."
exe_and_grep_q "rsync --version | head -1" "^rsync  version 3\\."
echo_done
