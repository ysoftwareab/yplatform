#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Python pyenv packages..."

# pyenv deps https://github.com/pyenv/pyenv/wiki/Common-build-problems
if [[ "${OS_SHORT}" = "linux" ]]; then
    DPKGS="$(cat <<-EOF
build-essential
libssl-dev
zlib1g-dev
libbz2-dev
libreadline-dev
libsqlite3-dev
wget
curl
llvm
libncurses5-dev
libncursesw5-dev
xz-utils
tk-dev
libffi-dev
liblzma-dev
python-openssl
git
EOF
)"
apt_install "${DPKGS}"
unset DPKGS
fi

BREW_FORMULAE="$(cat <<-EOF
pyenv
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
eval "$(pyenv init -)"
mkdir -p ~/.pyenv/versions
for PYTHON_VSN in $(brew --cellar python)/*; do
    ln -sf ${PYTHON_VSN} ~/.pyenv/versions/
done
unset PYTHON_VSN
echo_done

echo_do "brew: Testing Python pyenv packages..."
exe_and_grep_q "pyenv --version | head -1" "^pyenv "
echo_done
