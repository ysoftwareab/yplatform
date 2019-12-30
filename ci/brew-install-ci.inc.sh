#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing CI packages..."
BREW_FORMULAE="$(cat <<-EOF
git
jq
rsync
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done

echo_do "brew: Testing CI packages..."
exe_and_grep_q "git --version | head -1" "^git version 2\\."
exe_and_grep_q "jq --version | head -1" "^jq\\-1\\."
exe_and_grep_q "rsync --version | head -1" "^rsync  version 3\\."
echo_done

echo_do "brew: Unlink keg-only packages..."
BREW_FORMULAE="$(brew info --json=v1 --installed | \
    jq -r 'map(select(.keg_only == true and .linked_keg != null)) | map(.name) | .[]')"
echo "${BREW_FORMULAE}"
echo "${BREW_FORMULAE}" | xargs -L1 brew unlink
unset FORMULA
unset BREW_FORMULAE
echo_done
