#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing CI packages..."
else
    echo_do "brew: Installing CI packages..."
    # NOTE 'findutils' provides 'find' with '-min/maxdepth' and '-printf'
    # NOTE 'findutils' provides 'xargs', because the OSX version has no 'xargs -r'
    BREW_FORMULAE="$(cat <<-EOF
git
findutils
jq
tmate
EOF
)"
    brew_install "${BREW_FORMULAE}"
    unset BREW_FORMULAE
    echo_done

    echo_do "brew: Testing CI packages..."
    exe_and_grep_q "git --version | head -1" "^git version 2\."
    exe_and_grep_q "jq --version | head -1" "^jq-1\."
    exe_and_grep_q "tmate -V | head -1" "^tmate 2\."
    # need an extra condition, because the original one fails intermitently
    # exe_and_grep_q "xargs --help 2>&1" "no-run-if-empty"
    echo | xargs -r false || {
        echo_err "Your xargs doesn't have a working -r (short for --no-run-of-empty) option."
        exe_and_grep_q "xargs --help 2>&1" "no-run-if-empty"
        exit 1
    }
    echo_done
fi

[[ "${GITHUB_ACTIONS:-}" != "true" ]] || {
    [[ "${OS_SHORT}" != "darwin" ]] || {
        echo_do "Uninstalling Python 2.7..."
        set -x
        # uninstall Python 2.7, or else we get symlink conflicts, etc
        ${SF_SUDO} rm -rf /Applications/Python\ 2.7
        ${SF_SUDO} rm -rf /Library/Frameworks/Python.framework
        find /usr/local/bin -type l -print0 | \
            xargs -0 stat -f "%N %Y" | \
            grep "/Library/Frameworks/Python\.framework" | \
            cut -d" " -f1 | while read -r PYTHON2_BIN; do
            ${SF_SUDO} rm -rf ${PYTHON2_BIN}
        done
        unset PYTHON2_BIN
        set +x
        echo_done
    }
}

if git log -1 --format="%B" | grep -q "\[debug ci\]"; then
    echo_info "Detected '[debug ci]' marker in git commit message."
    echo_info "Starting a tmate session and exiting"
    ${SUPPORT_FIRECLOUD_DIR}/bin/tmate-shell
    exit 1
fi
