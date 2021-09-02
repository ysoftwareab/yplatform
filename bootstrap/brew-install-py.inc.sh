#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Python packages..."
brew_install_one_unless python "python3 --version 2>&1 | head -1" "^Python 3\."
brew_install_one_unless python "pip3 --version | head -1" "^pip "
echo_done
