#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Python packages..."
BREW_FORMULAE="$(cat <<-EOF
python@2
python@3
pyenv
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
eval "$(pyenv init -)"
mkdir -p ~/.pyenv/versions
for f in $(brew --cellar python@2)/* $(brew --cellar python@3)/*; do
    ln -sf $f ~/.pyenv/versions/
done
echo_done

echo_do "brew: Testing Python packages..."
exe_and_grep_q "python2 --version 2>&1 | head -1" "^Python 2\\."
exe_and_grep_q "python3 --version 2>&1 | head -1" "^Python 3\\."
exe_and_grep_q "pip2 --version | head -1" "^pip "
exe_and_grep_q "pip3 --version | head -1" "^pip "
exe_and_grep_q "pyenv --version | head -1" "^pyenv "
echo_done

# FIXME temporary fix
# See https://github.com/pypa/pipenv/issues/3395
# See https://github.com/pypa/virtualenv/issues/1270

# pipenv hasn't been released in a while, so we take a newer unreleased version straight from the git repo
# https://github.com/pypa/pipenv/commit/2549656dc09e132d8ba2fa6327c939f5f9a951b7 was chosen
# because it has a green CI run https://github.com/pypa/pipenv/runs/361861300
PIPENV_TAG=2549656dc09e132d8ba2fa6327c939f5f9a951b7
echo_do "brew: Installing pipenv@${PIPENV_TAG} via pip3..."
brew uninstall --force pipenv
pip3 install git+https://github.com/pypa/pipenv.git@${PIPENV_TAG}
exe_and_grep_q "pipenv --version | head -1" "^pipenv, version 2018.11.27.dev0"
echo_done
