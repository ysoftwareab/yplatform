#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing dev packages..."
source ${YP_DIR}/bootstrap/brew-install-common.inc.sh
source ${YP_DIR}/bootstrap/brew-install-aws.inc.sh
source ${YP_DIR}/bootstrap/brew-install-git-diff.inc.sh
source ${YP_DIR}/bootstrap/brew-install-py.inc.sh

brew_install_one_unless jid "jid --version | head -1" "^jid version v0\."
brew_install_one_unless tmate "tmate -V | head -1" "^tmate 2\."
# NOTE allow ttyrec to fail. May fail with
# ttyrec.c:74:18: fatal error: util.h: No such file or directory
# brew_install_one_unless ttyrec "ttyrec -e 'echo 123' $(mktemp -t yplatform.XXXXXXXXXX) | head -1" "123" -Fx || true
# NOTE ttyrec might even send sigterm 143 with "Out of pty's". Install on best effort
brew_install_one ttyrec
echo_done
