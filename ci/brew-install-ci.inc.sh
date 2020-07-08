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
# need an extra condition, because the original one fails intermitently
# exe_and_grep_q "xargs --help 2>&1" "no\\-run\\-if\\-empty"
echo | xargs -r false || {
    echo_err "Your xargs doesn't have a working -r (short for --no-run-of-empty) option."
    exe_and_grep_q "xargs --help 2>&1" "no\\-run\\-if\\-empty"
    exit 1
}
echo_done

echo_do "brew: Unlink keg-only packages..."
BREW_FORMULAE="$(brew info --json=v1 --installed | \
    jq -r 'map(select(.keg_only == true and .linked_keg != null)) | map(.name) | .[]')"
echo -n "${BREW_FORMULAE}" | while read -r BREW_FORMULA; do
    echo_info "brew unlink ${BREW_FORMULA}"
    brew unlink ${BREW_FORMULA} || {
        echo_warn "Failed to unlink formula ${BREW_FORMULA}."
        echo_skip "brew unlink ${BREW_FORMULA}"
    }
done
unset BREW_FORMULAE
echo_done
