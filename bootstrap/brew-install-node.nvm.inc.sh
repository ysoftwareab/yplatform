#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing NVM packages..."

export NVM_DIR=${NVM_DIR:-${HOME}/.nvm}
mkdir -p ${NVM_DIR}

# NOTE can't run brew_install_one_unless because we need to activate nvm
# brew_install_one_unless nvm "nvm --version | head -1" "^0\."
exe_and_grep_q "nvm --version | head -1" "^0\." >/dev/null || brew_install_one nvm

echo_do "Enabling NVM..."
NOUNSET_STATE="$(set +o | grep nounset)"
set +u
# shellcheck disable=SC1091
source $(brew --prefix nvm)/nvm.sh --no-use
eval "${NOUNSET_STATE}"
unset NOUNSET_STATE
echo_done

exe_and_grep_q "nvm --version | head -1" "^0\."

NODE_VSN=
[[ ! -f .nvmrc ]] || {
    NODE_VSN="$(cat .nvmrc)"
    echo_do "Activating node ${NODE_VSN} via NVM (as per .nvmrc)..."
}
[[ -z "${NODE_VSN:-}" ]] || {
    exe nvm install ${NODE_VSN} # and use
    exe node --version
    exe npm --version

    if nvm list --no-colors | grep -q system; then
        exe nvm reinstall-packages system

        # the command above skips 'npm'
        SYSTEM_NPM_VSN=$(nvm use system >/dev/null; npm --version)
        (
            cd ${NVM_DIR}/versions/node/$(node --version)/lib
            npm install --global-style npm@${SYSTEM_NPM_VSN}
        )
        unset SYSTEM_NPM_VSN

        exe npm --version
    fi
    echo_done
}
unset NODE_VSN

echo_done
