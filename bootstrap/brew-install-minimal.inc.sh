#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing minimal packages..."
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-core.inc.sh
# NOTE installing formulas that depend on python might exibit
# - reinstalling 1 broken dependent from source
# - bad interpreter
# This is due to Cellar/opt/python@3.9 not having any content but a 3.9.5-reinstall folder.
# see https://github.com/Homebrew/homebrew-core/issues/70497
# We experience this only on centos-8 now when installing docker-compose,
# but historically it has been a problem for aws-cli as well on ubuntu.
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-py.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-asdf.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-node.inc.sh
{
    TMP_NQ=$(mktemp -t firecloud.XXXXXXXXXX)
    case ${OS_RELEASE_ID} in
        alpine)
            # "brew install nq" will trigger segmentation fault when calling 'nq'
            magic_install_one_if nq "nq echo 123 | tee ${TMP_NQ} | head -1" "^,"
            ;;
        *)
            brew_install_one_if nq "nq echo 123 | tee ${TMP_NQ} | head -1" "^,"
            ;;
    esac
    rm -f $(cat ${TMP_NQ})
    rm -f ${TMP_NQ}
    unset TMP_NQ
}
echo_done
