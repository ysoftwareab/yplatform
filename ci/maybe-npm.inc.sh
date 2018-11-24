#!/usr/bin/env bash
set -euo pipefail

# optional
which npm >/dev/null 2>&1 || return 0

echo_do "Installing npm, json..."
npm install --global npm
npm install --global json
echo_done
