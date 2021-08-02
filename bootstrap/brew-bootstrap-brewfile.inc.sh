#!/usr/bin/env bash
set -euo pipefail

function hide_package_manager_update() {
    local PACKAGE_MANAGER="$1"

    echo_info "Hiding '${PACKAGE_MANAGER}_update' as 'force_${PACKAGE_MANAGER}_update'."
    echo_info "Running 'force_${PACKAGE_MANAGER}_update' will make the system unpredictable."
    eval "force_$(declare -f ${PACKAGE_MANAGER}_update)"
    eval "${PACKAGE_MANAGER}_update() { \
        echo \"[ERR ] Updating ${PACKAGE_MANAGER} will make the system unpredictable.\"; \
        echo \"[INFO] Call 'force_${PACKAGE_MANAGER}_update' instead, but only if you really need to.\"; \
        exit 1; \
    }"
}
hide_package_manager_update magic
if which apt-get >/dev/null 2>&1; then
    hide_package_manager_update apt
elif which yum >/dev/null 2>&1; then
    hide_package_manager_update yum
elif which pacman >/dev/null 2>&1; then
    hide_package_manager_update pacman
elif which apk >/dev/null 2>&1; then
    hide_package_manager_update apk
fi
hide_package_manager_update brew

BREWFILE_INC_SH=${GIT_ROOT}/Brewfile.inc.sh
[[ -f "${BREWFILE_INC_SH}" ]] || {
    echo_err "No ${BREWFILE_INC_SH} file present."
    return 1
}
echo_do "Sourcing ${BREWFILE_INC_SH}..."
source ${BREWFILE_INC_SH}
echo_done
unset BREWFILE_INC_SH
