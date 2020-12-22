#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Python pipenv packages..."
brew_install_one_if pipenv "pipenv --version | head -1" "^pipenv, "
echo_done
