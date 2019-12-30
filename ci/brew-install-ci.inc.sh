#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Unlink keg-only packages..."
BREW_FORMULAE="$(brew info --json=v1 --installed | \
    jq -r 'map(select(.keg_only == true and .linked_keg != null)) | map(.name) | .[]')"
cat "${BREW_FORMULAE}"
while read -u3 FORMULA; do
    brew unlink ${FORMULA} || true
done 3< <(echo "${BREW_FORMULAE}")
unset FORMULA
unset BREW_FORMULAE
echo_done

echo_do "brew: Installing CI packages..."
BREW_FORMULAE="$(cat <<-EOF
git
rsync
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done

echo_do "brew: Testing CI packages..."
exe_and_grep_q "git --version | head -1" "^git version 2\\."
exe_and_grep_q "rsync --version | head -1" "^rsync  version 3\\."
echo_done
