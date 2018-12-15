#!/usr/bin/env bash
set -euo pipefail

# optional
which npm >/dev/null 2>&1 || return 0

# icu4c needs to be installed via homebrew
echo_do "brew: (Re)Installing NodeJS requirements..."
BREW_FORMULAE="$(cat <<-EOF
icu4c
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done


echo_do "Installing/Upgrading npm, json..."
npm install --global npm
npm install --global json
echo_done

# test
exe_and_grep_q "npm --version | head -1" "^6\."
exe_and_grep_q "json --version | head -1" "^json 9\."
