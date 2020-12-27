#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing CI packages..."
# NOTE 'findutils' provides 'find' with '-min/maxdepth' and '-printf'
# NOTE 'findutils' provides 'xargs', because the OSX version has no 'xargs -r'
brew_install_one_if findutils "find --version | head -1" "^find (GNU findutils) 4\."
brew_install_one_if git "git --version | head -1" "^git version 2\."
brew_install_one_if jq "jq --version | head -1" "^jq-1\."
brew_install_one_if tmate "tmate -V | head -1" "^tmate 2\."

# need an extra condition, because the original one fails intermitently
# exe_and_grep_q "xargs --help 2>&1" "no-run-if-empty"
echo | xargs -r false || {
    echo_err "Your xargs doesn't have a working -r (short for --no-run-of-empty) option."
    exe_and_grep_q "xargs --help 2>&1" "no-run-if-empty"
    exit 1
}
echo_done

if git log -1 --format="%B" | grep -q "\[debug ci\]"; then
    echo_info "Detected '[debug ci]' marker in git commit message."
    echo_info "Starting a tmate session and exiting"
    ${SUPPORT_FIRECLOUD_DIR}/bin/tmate-shell
    exit 1
fi
