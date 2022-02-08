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

[[ ! -f .nvmrc ]] || {
    NODE_VSN="$(cat .nvmrc)"
    echo_do "Installing node@${NODE_VSN} via NVM (as per .nvmrc)..."
    yp::nvm_install ${NODE_VSN}
    nvm use system # revert to homebrew's version
    unset NODE_VSN
    echo_done
}

echo_done
