#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing asdf..."

# NOTE can't run brew_install_one_unless because we need to activate asdf
# brew_install_one_unless asdf "asdf --version | head -1" "^0\."
exe_and_grep_q "asdf --version | head -1" "^v0\." >/dev/null || {
    ASDF_DIR="${ASDF_DIR:-${HOME}/.asdf}"
    [[ ! -d "${ASDF_DIR}" ]] || rm -rf "${ASDF_DIR}"
    unset ASDF_DIR
    brew_install_one asdf
}

echo_do "Enabling asdf..."
NOUNSET_STATE="$(set +o | grep nounset)"
set +u
# shellcheck disable=SC1091
source $(brew --prefix)/opt/asdf/asdf.sh
eval "${NOUNSET_STATE}"
unset NOUNSET_STATE
echo_done

exe_and_grep_q "asdf --version | head -1" "^v0\."

# install nodejs plugin by default
# help also as a workaround for https://github.com/asdf-vm/asdf/issues/1022
{ asdf plugin list || true; } | grep -q "^nodejs$" || asdf plugin add nodejs

[[ ! -f .tool-versions ]] || {
    ${YP_DIR}/bin/asdf-plugin-add-deps
}

echo_do "asdf: Printing info..."
asdf info
echo_done

echo_done
