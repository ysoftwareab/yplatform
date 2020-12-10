#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Python packages..."
BREW_FORMULAE="$(cat <<-EOF
python
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done

echo_do "brew: Testing Python packages..."
exe_and_grep_q "python3 --version 2>&1 | head -1" "^Python 3\."
exe_and_grep_q "pip3 --version | head -1" "^pip "
echo_done
