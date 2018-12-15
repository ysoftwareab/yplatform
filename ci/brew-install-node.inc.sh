#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing NodeJS..."
BREW_FORMULAE="$(cat <<-EOF
node
nvm
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done

echo_do "Installing npm, json..."
npm install --global npm
npm install --global json
echo_done

# test
exe_and_grep_q "node --version | head -1" "^v"
exe_and_grep_q "npm --version | head -1" "^6\."
exe_and_grep_q "json --version | head -1" "^json 9\."
