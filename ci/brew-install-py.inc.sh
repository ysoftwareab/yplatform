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

# test
exe_and_grep_q "python2 --version 2>&1 | head -1" "^Python 2\\."
exe_and_grep_q "python3 --version 2>&1 | head -1" "^Python 3\\."
exe_and_grep_q "pip2 --version | head -1" "^pip "
exe_and_grep_q "pip3 --version | head -1" "^pip "
exe_and_grep_q "pyenv --version | head -1" "^pyenv "
exe_and_grep_q "pipenv --version | head -1" "^pipenv, version "
