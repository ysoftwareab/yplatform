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
echo_do "brew: Installing 'pipenv 2018.10.13'..."
HOMEBREW_CORE_GUC=https://raw.githubusercontent.com/Linuxbrew/homebrew-core
PIPENV_2018_10_13=${HOMEBREW_CORE_GUC}/494b0638a632244d25aaf2bd2292ae54c99ffa94/Formula/pipenv.rb
brew uninstall --force pipenv
brew install ${PIPENV_2018_10_13}
brew pin pipenv
exe_and_grep_q "pipenv --version | head -1" "^pipenv, version 2018.10.13"
echo_done
