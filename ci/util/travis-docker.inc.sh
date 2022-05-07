#!/usr/bin/env bash
set -euo pipefail

function yp_run_docker_ci_in_travis() {
    [[ "${YP_CI_PLATFROM:-}" = "travis" ]] || return 1

    (
        source ${YP_DIR}/bootstrap/brew-util.inc.sh
        apt_update
        apt_install expect # install unbuffer
        apt_install pv
    )

    yp_run_docker_ci_image "$(yp_get_docker_ci_image)" "${HOME}" yp-docker-ci-travis
}
