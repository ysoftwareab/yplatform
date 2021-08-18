#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing minimal packages..."
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-core.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-asdf.inc.sh
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
