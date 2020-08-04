#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Python pipenv packages..."
BREW_FORMULAE="$(cat <<-EOF
pipenv
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done

echo_do "brew: Testing Python pipenv packages..."
exe_and_grep_q "pipenv --version | head -1" "^pipenv, "
echo_done
