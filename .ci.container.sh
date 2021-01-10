#!/usr/bin/env bash

# shellcheck disable=SC2034
SF_DOCKER_CI_IMAGE=false

function ci_run_script() {
    cd dockerfiles/${GITHUB_MATRIX_CONTAINER}
    SF_CI_BREW_INSTALL=${GITHUB_MATRIX_SF_CI_BREW_INSTALL} ./build
}

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
