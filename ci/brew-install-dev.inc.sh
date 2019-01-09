#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing dev packages..."
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-common.inc.sh
echo_done

cat <<-EOF
Append 'source ˙~/${SUPPORT_FIRECLOUD_DIR#${HOME}/}/priv/dev.inc.sh'
to your '~/.bashrc' or '~/.zshrc' or similar.

Restart your shell, and you're good to go.
EOF
