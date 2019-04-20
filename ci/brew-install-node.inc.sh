#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing NodeJS packages..."

# force node bottle on Travis, compiling node fails or takes forever
NODE_FORMULA=node
[[ "${TRAVIS:-}" != "true" ]] || {
    cd $(brew --repo homebrew/core)
    git fetch --depth 1000
    NODE_BOTTLE_COMMIT=$(git log -1 --pretty=format:"%H" --grep update --grep bottle Formula/node.rb)
    NODE_FORMULA="https://raw.githubusercontent.com/Homebrew/linuxbrew-core/${NODE_BOTTLE_COMMIT}/Formula/node.rb"
}

BREW_FORMULAE="$(cat <<-EOF
${NODE_FORMULA}
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
npm install --global npm@6
npm install --global json@9
echo_done

echo_do "brew: Testing NodeJS packages..."
exe_and_grep_q "node --version | head -1" "^v"
exe_and_grep_q "npm --version | head -1" "^6\."
exe_and_grep_q "json --version | head -1" "^json 9\."
echo_done
