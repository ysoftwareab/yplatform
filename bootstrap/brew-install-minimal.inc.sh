#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing minimal packages..."
source ${YP_DIR}/bootstrap/brew-install-core.inc.sh
# NOTE installing formulas that depend on python might exibit
# - reinstalling 1 broken dependent from source
# - bad interpreter
# This is due to Cellar/opt/python@3.9 not having any content but a 3.9.5-reinstall folder.
# see https://github.com/Homebrew/homebrew-core/issues/70497
# We experience this only on centos-8 now when installing docker-compose,
# but historically it has been a problem for aws-cli as well on ubuntu.
# NOTE we install by force via homebrew, without checking system's python
# because formulas like docker-compose, dependent on python, will no use the system's python
# source ${YP_DIR}/bootstrap/brew-install-py.inc.sh
brew_install_one python

source ${YP_DIR}/bootstrap/brew-install-asdf.inc.sh
source ${YP_DIR}/bootstrap/brew-install-node.inc.sh
{
    TMP_NQ=$(mktemp -t yplatform.XXXXXXXXXX)
    case ${OS_SHORT} in
        linux-alpine)
            # NOTE "brew install nq" will trigger segmentation fault when calling 'nq'
            magic_install_one_unless nq "nq echo 123 | tee ${TMP_NQ} | head -1" "^,"
            ;;
        linux-*)
            # NOTE no bottle available for linuxbrew
            brew_install_one_unless "nq --build-from-source" "nq echo 123 | tee ${TMP_NQ} | head -1" "^,"
            ;;
        darwin-*)
            brew_install_one_unless nq "nq echo 123 | tee ${TMP_NQ} | head -1" "^,"
            ;;
        *)
            echo_err "Cannot handle OS_SHORT=${OS_SHORT} OS_RELEASE_ID=${OS_RELEASE_ID}."
            ;;
    esac
    rm -f $(cat ${TMP_NQ})
    rm -f ${TMP_NQ}
    unset TMP_NQ
}
echo_done
