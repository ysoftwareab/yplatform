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
exe_and_grep_q "cat --version | head -1" "^cat (GNU coreutils) 8\\." || prompt_q_to_continue
exe_and_grep_q "diff --version | head -1" "^diff (GNU diffutils) 3\\." || prompt_q_to_continue
exe_and_grep_q "envsubst --version | head -1" "^envsubst (GNU gettext-runtime) 0.20\\." || prompt_q_to_continue
exe_and_grep_q "find --version | head -1" "^find (GNU findutils) 4\\." || prompt_q_to_continue
exe_and_grep_q "grep --version | head -1" "^grep (GNU grep) 3\\." || prompt_q_to_continue
exe_and_grep_q "sed --version | head -1" "^sed (GNU sed) 4\\." || prompt_q_to_continue
exe_and_grep_q "tar --version | head -1" "^tar (GNU tar) 1\\." || prompt_q_to_continue
echo_done

fi
