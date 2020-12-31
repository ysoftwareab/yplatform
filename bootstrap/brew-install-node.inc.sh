#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing NodeJS packages..."
# NOTE node can be installed in such a way that
# - "npm i -g" executables are not available in PATH
# - "npm i -g" is missing the right permissions
# therefore we always install it via homebrew
# unless_exe_and_grep_q_then "node --version | head -1" "^v" brew_install_one node
brew_install_one node
exe_and_grep_q "node --version | head -1" "^v"

# allow npm upgrade to fail on WSL; fails with EACCESS
unless_exe_and_grep_q_then "npm --version | head -1" "^6\." \
    npm install --global --force npm@6 || ${SUPPORT_FIRECLOUD_DIR}/bin/is-wsl

brew_install_one n "n --version | head -1" "^6\."

unless_exe_and_grep_q_then "json --version | head -1" "^json 9\." \
    npm install --global json@9
echo_done
