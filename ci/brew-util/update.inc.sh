#!/usr/bin/env bash
set -euo pipefail

function brew_update() {
    echo_do "brew: Updating..."
    brew update >/dev/null
    brew outdated
    echo_done
}
