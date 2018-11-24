#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Python..."
BREW_FORMULAE="$(cat <<-EOF
python@2
python@3
pyenv
pipenv
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
eval "$(pyenv init -)"
echo_done
