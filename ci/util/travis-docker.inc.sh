#!/usr/bin/env bash
set -euo pipefail

function yp_run_docker_ci_in_travis() {
    (
        source ${YP_DIR}/bootstrap/brew-util.inc.sh
        apt_update
        apt_install expect # install unbuffer
        apt_install pv
    )

    yp_run_docker_ci_image "$(yp_get_docker_ci_image)" "${HOME}" sf-docker-ci-travis
}
