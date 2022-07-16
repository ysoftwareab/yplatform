#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing NodeJS packages..."
# NOTE node can be installed in such a way that
# - "npm i -g" executables are not available in PATH
# - "npm i -g" is missing the right permissions
# therefore we always install it via homebrew
# brew_install_one_unless node "node --version | head -1" "^v"
# brew_install_one node

if ${YP_DIR}/bin/is-wsl; then
    # 18.4.0+ versions crash with
    # -bash: /home/linuxbrew/.linuxbrew/bin/node: cannot execute binary file: Exec format error
    # see https://github.com/Homebrew/homebrew-core/issues/105968
    brew_install_one ysoftwareab/tap/node@1380
else
    brew_install_one node
fi

exe_and_grep_q "node --version | head -1" "^v"

if [[ "${CI:-}" = "true" ]] && ${YP_DIR}/bin/is-wsl; then
    # it just hangs
    echo_skip "brew: Installing deno..."
else
    brew_install_one_unless deno "deno --version | head -1" "^deno 1\."
fi
brew_install_one_unless pnpm "pnpm --version | head -1" "^[67]\."
brew_install_one_unless yarn "yarn --version | head -1" "^1\."

# allow npm upgrade to fail on WSL; fails with EACCESS
unless_exe_and_grep_q "npm --version | head -1" "^6\." \
    npm install --global --force npm@6 || ${YP_DIR}/bin/is-wsl

case ${OS_SHORT}-${OS_RELEASE_ID} in
    linux-alpine)
        # see https://github.com/ysoftwareab/yplatform/runs/5084770376?check_suite_focus=true
        # glibc related failure
        echo_skip "brew: Installing ysoftwareab/tap/vscode-dev-container-cli..."
        ;;
    darwin-*|linux-amzn|linux-arch|linux-centos|linux-rhel|linux-debian|linux-ubuntu)
        brew_install_one_unless ysoftwareab/tap/vscode-dev-container-cli \
            "devcontainer --help | head -1" "^devcontainer "
        ;;
    *)
        echo_err "${OS_SHORT}-${OS_RELEASE_ID} is an unsupported OS for installing Docker."
        exit 1
        ;;
esac


brew_install_one_unless ysoftwareab/tap/json "json --version | head -1" "^json 11\."

brew_install_one_unless ysoftwareab/tap/semver "semver --help | head -1" "^SemVer 7\."

echo_done
