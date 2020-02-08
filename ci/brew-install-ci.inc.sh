#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing CI packages..."
# 'findutils' provides 'xargs', because the OSX version has no 'xargs -r'
BREW_FORMULAE="$(cat <<-EOF
git
findutils
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
exe_and_grep_q "xargs --help" "no-run-if-empty"
echo_done

echo_do "brew: Unlink keg-only packages..."
BREW_FORMULAE="$(brew info --json=v1 --installed | \
    jq -r 'map(select(.keg_only == true and .linked_keg != null)) | map(.name) | .[]')"
echo "${BREW_FORMULAE}"
echo -n "${BREW_FORMULAE}" | xargs -r -L1 brew unlink
unset BREW_FORMULAE
echo_done
