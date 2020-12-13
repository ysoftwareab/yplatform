#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing dev packages..."
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-common.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-aws.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-py.inc.sh

BREW_FORMULAE="$(cat <<-EOF
jid
tmate
ttyrec
EOF
)"
# ok if installing a dev dependency fails
# brew_install "${BREW_FORMULAE}"
echo "${BREW_FORMULAE}" | while read -r BREW_FORMULA; do
    brew_install "${BREW_FORMULA}" || true
done
unset BREW_FORMULAE

echo_done

echo_do "brew: Testing dev packages..."
exe_and_grep_q "jid --version | head -1" "^jid version v0\."
exe_and_grep_q "tmate -V | head -1" "^tmate 2\."
echo_done
