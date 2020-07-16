#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing NVM packages..."

[ -n "${NVM_DIR:-}" ] || export NVM_DIR=~/.nvm
mkdir -p ${NVM_DIR}

BREW_FORMULAE="$(cat <<-EOF
nvm
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE

(
    set +u
    source $(brew --prefix nvm)/nvm.sh --no-use

    nvm install node
    nvm reinstall-packages system
    nvm alias default node

    [[ ! -f .nvmrc ]] || {
        nvm install
        nvm reinstall-packages system
        nvm alias default $(nvm current)
    }
)
echo_done

echo_do "brew: Testing NVM packages..."
(
    set +u
    source $(brew --prefix nvm)/nvm.sh --no-use
    exe_and_grep_q "nvm --version | head -1" "^0\."
)
echo_done
