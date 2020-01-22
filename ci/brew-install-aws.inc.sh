#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
echo_skip "brew: Installing AWS packages..."
else

echo_do "brew: Installing AWS packages..."
BREW_FORMULAE="$(cat <<-EOF
awscli
awslogs
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
aws configure set s3.signature_version s3v4
echo_done

echo_do "brew: Testing AWS packages..."
exe_and_grep_q "aws --version | head -1" "^aws-cli/1\\."
exe_and_grep_q "awslogs --version | head -1" "^awslogs 0\\."
echo_done

fi
