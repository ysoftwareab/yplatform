#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing NodeJS packages..."

# force node bottle on CI, compiling node fails or takes forever
NODE_FORMULA=node
[[ "${CI:-}" != "true" ]] || {
    cd $(brew --repo homebrew/core)
    git fetch --depth 1000
    BREW_TEST_BOT=BrewTestBot
    [[ "$(uname -s)" != "Linux" ]] || BREW_TEST_BOT=LinuxbrewTestBot
    NODE_BOTTLE_COMMIT=$(
        git log -1 \
            --first-parent \
            --pretty=format:"%H" \
            --author ${BREW_TEST_BOT} \
            --grep update \
            --grep bottle \
            Formula/node.rb || echo master
    )
    [[ "${NODE_BOTTLE_COMMIT}" != "master" ]] || {
        echo_err "Failed to find a brew bottle for node formula."
        echo_err "and node cannot be built from source on Travis due to available resources."
        exit 1
    }
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
