#!/usr/bin/env bash
set -euo pipefail

function brew_update() {
    echo_do "brew: Updating..."
    # 'brew update' is currently flaky, resulting in 'transfer closed with outstanding read data remaining'
    # see https://github.com/Homebrew/homebrew-core/issues/61772
    brew update >/dev/null || brew update --verbose
    brew outdated
    echo_done
}
