#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Python pyenv packages..."

# workaround for failing to install `perl` (pyenv > autoconf > perl)
# fatal error: xlocale.h: No such file or directory
if [[ "${OS_SHORT}" = "linux" ]] && [[ ! -f /usr/include/xlocale.h ]]; then
    ${SUDO} ln -s /usr/include/locale.h /usr/include/xlocale.h
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
