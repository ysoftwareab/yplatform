#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing dev packages..."
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-common.inc.sh

BREW_FORMULAE="$(cat <<-EOF
jid
tmate
ttyrec
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE

echo_done
