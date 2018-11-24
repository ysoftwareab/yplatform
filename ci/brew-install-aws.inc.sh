#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing AWS utils..."
BREW_FORMULAE="$(cat <<-EOF
awscli
awslogs
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
aws configure set s3.signature_version s3v4
echo_done
