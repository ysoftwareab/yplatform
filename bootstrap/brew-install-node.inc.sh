#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing NodeJS packages..."
else
    echo_do "brew: Installing NodeJS packages..."

    # force node bottle on CI, compiling node fails or takes forever
    NODE_FORMULA=node
    [[ "${CI:-}" != "true" ]] || {
        BREW_CORE_TAP_DIR=$(brew --repo homebrew/core)
        git -C ${BREW_CORE_TAP_DIR} fetch --depth 1000
        BREW_TEST_BOT=BrewTestBot
        BREW_REPO_SLUG=Homebrew/homebrew-core
        [[ "${OS_SHORT}" != "linux" ]] || {
            BREW_TEST_BOT=LinuxbrewTestBot
            BREW_REPO_SLUG=Homebrew/linuxbrew-core
        }
        NODE_BOTTLE_COMMIT=$(
            git -C ${BREW_CORE_TAP_DIR} log -1 \
                --first-parent \
                --pretty=format:"%H" \
                --author ${BREW_TEST_BOT} \
                --grep update \
                --grep bottle \
                Formula/node.rb
        )
        if [[ -n "${NODE_BOTTLE_COMMIT}" ]]; then
            # NOTE brew has deprecated installing from a URL, but installing from a local file should still work
            # see https://github.com/Homebrew/brew/pull/7660
            # Installing from a URL gives:
            # Error: Calling Installation of node from a GitHub commit URL is disabled! Use 'brew extract node' to stable tap on GitHub instead.
            RAW_GUC_URL="https://raw.githubusercontent.com"
            NODE_FORMULA_URL="${RAW_GUC_URL}/${BREW_REPO_SLUG}/${NODE_BOTTLE_COMMIT}/Formula/node.rb"
            NODE_FORMULA=$(mktemp -d)/node.rb
            curl -fqsSL "${NODE_FORMULA_URL}" -o ${NODE_FORMULA}
            unset NODE_FORMULA_URL
            unset RAW_GUC_URL
        fi
        unset BREW_CORE_TAP_DIR
        unset BREW_REPO_SLUG
        unset BREW_TEST_BOT
        unset NODE_BOTTLE_COMMIT
    }

    brew_install_one "${NODE_FORMULA}"
    unset NODE_FORMULA

    # TODO remove once we can use node@14 (or npm@6)
    # see https://github.com/Homebrew/homebrew-core/pull/63410
    brew unlink node
    brew install ${SUPPORT_FIRECLOUD_DIR}/priv/node.rb || true
    brew switch node 14.14.0

    # allow npm upgrade to fail on WSL; fails with EACCESS
    npm install --global --force npm@6 || ${SUPPORT_FIRECLOUD_DIR}/bin/is-wsl
    npm install --global json@9
    echo_done

    echo_do "brew: Testing NodeJS packages..."
    exe_and_grep_q "node --version | head -1" "^v"
    exe_and_grep_q "npm --version | head -1" "^6\."
    exe_and_grep_q "json --version | head -1" "^json 9\."
    echo_done
fi
