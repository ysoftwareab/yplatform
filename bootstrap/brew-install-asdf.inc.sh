#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing asdf..."

# NOTE can't run brew_install_one_if because we need to activate asdf
# brew_install_one_if asdf "asdf --version | head -1" "^0\."
exe_and_grep_q "asdf --version | head -1" "^v0\." >/dev/null || brew_install_one asdf

echo_do "Enabling asdf..."
set +u
# shellcheck disable=SC1091
source $(brew --prefix asdf)/asdf.sh
set -u
echo_done

exe_and_grep_q "asdf --version | head -1" "^v0\."

# install nodejs plugin by default
# help also as a workaround for https://github.com/asdf-vm/asdf/issues/1022
asdf plugin list | grep -q "^nodejs$" || asdf plugin add nodejs

[[ ! -f .tool-versions ]] || {
    ${SUPPORT_FIRECLOUD_DIR}/bin/asdf-plugin-add-deps
}

echo_do "asdf: Printing info..."
asdf info
echo_done

echo_done
