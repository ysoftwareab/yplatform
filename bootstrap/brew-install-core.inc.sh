#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing core packages..."

# download binaries
${YP_DIR}/bin/editorconfig-checker -version >/dev/null
${YP_DIR}/bin/gitleaks -h >/dev/null
${YP_DIR}/bin/jq -h >/dev/null

brew_install_one_unless curl "curl --version | head -1" "^curl 7\."
brew_install_one_unless git "git --version | head -1" "^git version 2\."

brew_install_one_unless jq "jq --version | head -1" "^jq-1\."
# install if we're falling back to our jq proxy
[[ -f "${YP_DIR}/bin/.jq/jq" ]]
if_exe_and_grep_q "which jq" "^${YP_DIR}/bin/\.jq/jq$" brew_install_one jq

brew_install_one_unless shellcheck "shellcheck --version | head -2 | tail -1" "^version: 0\.7\."
brew_install_one_unless unzip "unzip --version 2>&1 | head -2 | tail -1" "^UnZip 6\."
brew_install_one_unless unzip "unzip --version 2>&1 | head -2 | tail -1" ", by Debian\."
brew_install_one_unless zip "zip --version 2>&1 | head -2 | tail -1" "Zip 3\.0"
brew_install_one_unless zip "zip --version 2>&1 | head -2 | tail -1" ", by Info-ZIP\."

source ${YP_DIR}/bootstrap/brew-install-gnu.inc.sh

echo_done
