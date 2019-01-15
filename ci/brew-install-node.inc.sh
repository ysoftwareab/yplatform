#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing NodeJS packages..."
BREW_FORMULAE="$(cat <<-EOF
node
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
npm install --global npm
npm install --global json
echo_done

echo_do "brew: Testing NodeJS packages..."
exe_and_grep_q "node --version | head -1" "^v"
exe_and_grep_q "npm --version | head -1" "^6\."
exe_and_grep_q "json --version | head -1" "^json 9\."
echo_done
