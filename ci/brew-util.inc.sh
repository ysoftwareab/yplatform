#!/usr/bin/env bash
set -euo pipefail

source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/apt.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/env.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/install.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/print.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util/update.inc.sh

function brew_brewfile_inc_sh() {
    echo_warn "Hiding 'apt_update' as 'force_apt_update'."
    echo_info "Running 'force_apt_update' will make the system unpredictable."
    eval "force_$(declare -f apt_update)"
    eval "apt_update() { \
        echo \"[ERR ] Updating Aptitude will make the system unpredictable.\"; \
        echo \"[INFO] Call 'force_apt_update' if you really need to, instead of 'apt_update'.\"; \
        exit 1; \
    }"

    echo_warn "Hiding 'brew_update' as 'force_brew_update'."
    echo_info "Running 'force_brew_update' will make the system unpredictable."
    eval "force_$(declare -f brew_update)"
    eval "brew_update() { \
        echo \"[ERR ] Updating HomeBrew will make the system unpredictable.\"; \
        echo \"[INFO] Call 'force_brew_update' if you really need to, instead of 'brew_update'.\"; \
        exit 1; \
    }"

    local BREWFILE_INC_SH=${GIT_ROOT}/Brewfile.inc.sh
    [[ -f "${BREWFILE_INC_SH}" ]] || {
        echo_err "No ${BREWFILE_INC_SH} file present."
        return 1
    }
    echo_info "Sourcing ${BREWFILE_INC_SH}..."
    source ${BREWFILE_INC_SH}
}
