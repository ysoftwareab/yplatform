#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Python pyenv packages..."

# pyenv deps https://github.com/pyenv/pyenv/wiki/Common-build-problems
if [[ "${OS_SHORT}" = "linux" ]]; then
    apt_install_one build-essential
    apt_install_one libssl-dev
    apt_install_one zlib1g-dev
    apt_install_one libbz2-dev
    apt_install_one libreadline-dev
    apt_install_one libsqlite3-dev
    apt_install_one wget
    apt_install_one curl
    apt_install_one llvm
    apt_install_one libncurses5-dev
    apt_install_one libncursesw5-dev
    apt_install_one xz-utils
    apt_install_one tk-dev
    apt_install_one libffi-dev
    apt_install_one liblzma-dev
    apt_install_one python-openssl
    apt_install_one git
fi

# NOTE can't run brew_install_one_unless because we need to activate pyenv
# brew_install_one_unless pyenv "pyenv --version | head -1" "^pyenv "
exe_and_grep_q "pyenv --version | head -1" "^pyenv " >/dev/null || brew_install_one pyenv
eval "$(pyenv init -)"
mkdir -p ${HOME}/.pyenv/versions
for PYTHON_VSN in "$(brew --cellar python)"/*; do
    ln -sfn ${PYTHON_VSN} ${HOME}/.pyenv/versions/
done
unset PYTHON_VSN
exe_and_grep_q "pyenv --version | head -1" "^pyenv "
echo_done
