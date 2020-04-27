#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing dev packages..."
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-common.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-aws.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-py.inc.sh

BREW_FORMULAE="$(cat <<-EOF
jid
tmate
ttyrec
EOF
)"
# ok if installing a dev dependency fails
# brew_install "${BREW_FORMULAE}"
echo "${BREW_FORMULAE}" | while read BREW_FORMULA; do
    brew_install "${BREW_FORMULA}" || true
done
unset BREW_FORMULAE

echo_done
