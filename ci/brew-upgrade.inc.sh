#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Upgrading..."
brew outdated
# trying to upgrade twice in case of intermediate complaints
brew upgrade || brew upgrade
echo_done
