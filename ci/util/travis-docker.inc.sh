#!/usr/bin/env bash
set -euo pipefail

function sf_run_docker_ci_in_travis() {
    (
        source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util.inc.sh
        apt_update
        apt_install expect # install unbuffer
        apt_install pv
    )

    sf_run_docker_ci_image "$(sf_get_docker_ci_image)" "${HOME}" sf-docker-ci-travis
}
