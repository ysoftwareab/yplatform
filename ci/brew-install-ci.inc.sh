#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Uninstall all packages..."
    echo_skip "brew: Installing CI packages..."
else
    echo_do "brew: Uninstall all packages..."
    BREW_FORMULAE="$(brew list)"
    [[ -z "${BREW_FORMULAE}" ]] || \
        brew uninstall --ignore-dependencies --force ${BREW_FORMULAE}
    unset BREW_FORMULAE
    echo_done

    echo_do "brew: Installing CI packages..."
    # 'findutils' provides 'xargs', because the OSX version has no 'xargs -r'
    BREW_FORMULAE="$(cat <<-EOF
git
findutils
jq
EOF
)"
    brew_install "${BREW_FORMULAE}"
    unset BREW_FORMULAE
    echo_done

    echo_do "brew: Testing CI packages..."
    exe_and_grep_q "git --version | head -1" "^git version 2\\."
    exe_and_grep_q "jq --version | head -1" "^jq\\-1\\."
    # need an extra condition, because the original one fails intermitently
    # exe_and_grep_q "xargs --help 2>&1" "no\\-run\\-if\\-empty"
    echo | xargs -r false || {
        echo_err "Your xargs doesn't have a working -r (short for --no-run-of-empty) option."
        exe_and_grep_q "xargs --help 2>&1" "no\\-run\\-if\\-empty"
        exit 1
    }
    echo_done
fi
