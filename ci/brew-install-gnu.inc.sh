#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing GNU packages..."
else
    echo_do "brew: Installing GNU packages..."
    BREW_FORMULAE="$(cat <<-EOF
coreutils
diffutils
findutils
gettext
gnu-sed
gnu-tar
gnu-which
grep
gzip
EOF
)"
    brew_install "${BREW_FORMULAE}"
    unset BREW_FORMULAE
    echo_done

    echo_do "brew: Testing GNU packages..."
    exe_and_grep_q "cat --version | head -1" "^cat (GNU coreutils) 8\\."
    exe_and_grep_q "diff --version | head -1" "^diff (GNU diffutils) 3\\."
    exe_and_grep_q "envsubst --version | head -1" "^envsubst (GNU gettext-runtime) 0.2[01]"
    exe_and_grep_q "find --version | head -1" "^find (GNU findutils) 4\\."
    exe_and_grep_q "grep --version | head -1" "^grep (GNU grep) 3\\."
    exe_and_grep_q "sed --version | head -1" "^sed (GNU sed) 4\\."
    exe_and_grep_q "tar --version | head -1" "^tar (GNU tar) 1\\."
    # need an extra condition, because the original one fails intermitently
    # exe_and_grep_q "xargs --help 2>&1" "no\\-run\\-if\\-empty"
    echo | xargs -r false || {
        echo_err "Your xargs doesn't have a working -r (short for --no-run-of-empty) option."
        exe_and_grep_q "xargs --help 2>&1" "no\\-run\\-if\\-empty"
        exit 1
    }
    echo_done
fi
