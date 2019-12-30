#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_BOOTSTRAP_SKIP_COMMON:-}" = "true" ]]; then
echo_info "brew: SF_BOOTSTRAP_SKIP_COMMON=${SF_BOOTSTRAP_SKIP_COMMON}"
echo_skip "brew: Installing common packages..."
else

echo_do "brew: Installing common packages..."
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-minimal.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-node.inc.sh
echo_done

fi
