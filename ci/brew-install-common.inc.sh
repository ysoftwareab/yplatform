#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
echo_skip "brew: Installing common packages..."
else

echo_do "brew: Installing common packages..."
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-minimal.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-node.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-py.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-aws.inc.sh
echo_done

fi
