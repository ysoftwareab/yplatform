#!/usr/bin/env bash
set -euo pipefail

(
    [[ "${OS}" != "linux" ]] || {
        # if a node bottle doesn't exist, we need to compile node with clang instead of gcc
        # to get around "out of memory" issues
        brew_install llvm
        export PATH=$(brew --prefix)/opt/llvm/bin:${PATH}
        export C=clang
        export CXX=clang++
        export LDFLAGS="-L$(brew --prefix)/opt/llvm/lib -Wl,-rpath,$(brew --prefix)/opt/llvm/lib"
    }

    echo_do "brew: Installing NodeJS packages..."
    BREW_FORMULAE="$(cat <<-EOF
node
EOF
)"
    brew_install "${BREW_FORMULAE}"
    unset BREW_FORMULAE
    npm install --global npm@6
    npm install --global json@9
    echo_done
)

echo_do "brew: Testing NodeJS packages..."
exe_and_grep_q "node --version | head -1" "^v"
exe_and_grep_q "npm --version | head -1" "^6\."
exe_and_grep_q "json --version | head -1" "^json 9\."
echo_done
