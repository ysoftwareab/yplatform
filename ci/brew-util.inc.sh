#!/usr/bin/env bash
set -euo pipefail

source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/apt.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/env.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/install.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/print.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/update.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/upgrade.inc.sh

function brew_brewfile_inc_sh() {
    local BREWFILE_INC_SH=${GIT_ROOT}/Brewfile.inc.sh
    [[ -f "${BREWFILE_INC_SH}" ]] || {
        echo_err "No ${BREWFILE_INC_SH} file present."
        return 1
    }
    echo_info "Sourcing ${BREWFILE_INC_SH}..."
    source ${BREWFILE_INC_SH}
}
