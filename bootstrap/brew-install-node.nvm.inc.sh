#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing NVM packages..."

export NVM_DIR=${NVM_DIR:-${HOME}/.nvm}
mkdir -p ${NVM_DIR}

# NOTE can't run brew_install_one_unless because we need to activate nvm
# brew_install_one_unless nvm "nvm --version | head -1" "^0\."
exe_and_grep_q "nvm --version | head -1" "^0\." >/dev/null || brew_install_one nvm

echo_do "Enabling NVM..."
set +u
# shellcheck disable=SC1091
source $(brew --prefix nvm)/nvm.sh --no-use
set -u
echo_done

exe_and_grep_q "nvm --version | head -1" "^0\."

[[ ! -f .nvmrc ]] || {
    nvm install

    if nvm list --no-colors | grep -q system; then
        nvm reinstall-packages system

        # the command above skips 'npm'
        SYSTEM_NPM_VSN=$(nvm use system >/dev/null; npm --version)
        cd ${NVM_DIR}/versions/node/$(node --version)/lib
        npm install --global-style npm@${SYSTEM_NPM_VSN}
        cd -
    fi

    echo_info "Activating node $(cat .nvmrc) via NVM (as per .nvmrc)..."
    nvm use
}

echo_done
