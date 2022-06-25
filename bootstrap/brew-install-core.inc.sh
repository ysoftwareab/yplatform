#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing core packages..."

# download binaries
${YP_DIR}/bin/editorconfig-checker -version >/dev/null
${YP_DIR}/bin/gitleaks -h >/dev/null
${YP_DIR}/bin/jq -h >/dev/null
${YP_DIR}/bin/jd -h >/dev/null
${YP_DIR}/bin/nanoseconds >/dev/null
${YP_DIR}/bin/yq -h >/dev/null

brew_install_one_unless curl "curl --version | head -1" "^curl 7\."
brew_install_one_unless dateutils "datetest --version | head -1" "^datetest 0\.4\."
brew_install_one_unless git "git --version | head -1" "^git version 2\."

brew_install_one_unless jq "jq --version | head -1" "^jq-1\."
# install if we're falling back to our jq proxy
[[ -f "${YP_DIR}/bin/.jq/jq" ]]
if_exe_and_grep_q "which jq" "^${YP_DIR}/bin/\.jq/jq$" brew_install_one jq

brew_install_one_unless jd "jd --version | head -1" "^jd version 1\."
# install if we're falling back to our jd proxy
[[ -f "${YP_DIR}/bin/.jd/jd" ]]
if_exe_and_grep_q "which jd" "^${YP_DIR}/bin/\.jd/jd$" brew_install_one jd

brew_install_one_unless jo "jo -v | head -1" "^jo 1\."
brew_install_one_unless openssh "ssh -V 2>&1 | head -1" "^OpenSSH_8\."
brew_install_one_unless shellcheck "shellcheck --version | head -2 | tail -1" "^version: 0\.[78]\."
brew_install_one_unless unzip "unzip --version 2>&1 | head -2 | tail -1" "^UnZip 6\."
brew_install_one_unless unzip "unzip --version 2>&1 | head -2 | tail -1" ", by Debian\."
brew_install_one_unless zip "zip --version 2>&1 | head -2 | tail -1" "Zip 3\.0"
brew_install_one_unless zip "zip --version 2>&1 | head -2 | tail -1" ", by Info-ZIP\."

brew_install_one_unless yq "yq --version | head -1" " version 4\."
# install if we're falling back to our yq proxy
[[ -f "${YP_DIR}/bin/.yq/yq" ]]
if_exe_and_grep_q "which yq" "^${YP_DIR}/bin/\.yq/yq$" brew_install_one yq

case ${OS_SHORT}-${OS_RELEASE_ID} in
    darwin-*)
        ;;
    linux-alpine)
        apk_install_one libplist
        [[ -e /usr/bin/plutil ]] || ${YP_SUDO:-} ln -s $(command -v plistutil) /usr/bin/plutil
        ;;
    linux-arch)
        pacman_install_one libplist
        [[ -e /usr/bin/plutil ]] || ${YP_SUDO:-} ln -s $(command -v plistutil) /usr/bin/plutil
        ;;
    linux-amzn|linux-centos|linux-rhel)
        yum_install_one libplist
        [[ -e /usr/bin/plutil ]] || ${YP_SUDO:-} ln -s $(command -v plistutil) /usr/bin/plutil
        ;;
    linux-debian|linux-ubuntu)
        apt_install_one libplist-utils
        [[ -e /usr/bin/plutil ]] || ${YP_SUDO:-} ln -s $(command -v plistutil) /usr/bin/plutil
        ;;
    *)
        echo_err "${OS_SHORT}-${OS_RELEASE_ID} is an unsupported OS for installing plistutil."
        exit 1
        ;;
esac

source ${YP_DIR}/bootstrap/brew-install-gnu.inc.sh

echo_done
