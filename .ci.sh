#!/usr/bin/env bash

# SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

function ci_run_deploy() {
    DOCKER_ORG=${DOCKER_ORG:-tobiipro}
    [[ -n "${DOCKER_USERNAME:-}" ]] || return
    [[ -n "${DOCKER_PASSWORD:-}" ]] || return
    [[ -e "/etc/os-release" ]] || return

    # temporary; should check instead if a docker repository exists for ${DOCKER_ORG}/${DOCKER_IMAGE_TAG}
    [[ "${SF_CI_BREW_INSTALL}" = "common" ]] || return

    RELEASE_ID="$(source /etc/os-release && echo ${ID})"
    RELEASE_VERSION_CODENAME="$(source /etc/os-release && echo ${VERSION_CODENAME})"
    DOCKER_IMAGE_TAG=sf-${RELEASE_ID}-${RELEASE_VERSION_CODENAME}
    DOCKERFILE=${SUPPORT_FIRECLOUD_DIR}/ci/${OS_SHORT}/Dockerfile.${RELEASE_ID}.${RELEASE_VERSION_CODENAME}
    [[ -f "${DOCKERFILE}" ]] || return

    # login
    echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

    # build
    docker build . --file ${DOCKERFILE} --tag ${DOCKER_IMAGE_TAG}
    docker images
    docker tag travis-ci-build-stages-demo ${DOCKER_ORG}/${DOCKER_IMAGE_TAG}

    # deploy
    docker push ${DOCKER_ORG}/${DOCKER_IMAGE_TAG}
}

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
