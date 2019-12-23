#!/usr/bin/env bash

# SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

function ci_run_before_deploy() {
    true
}

function ci_run_deploy_docker_image() {
    DOCKER_ORG=${DOCKER_ORG:-tobiipro}
    [[ -n "${DOCKER_USERNAME:-}" ]] || return
    [[ -n "${DOCKER_PASSWORD:-}" ]] || return
    [[ -e "/etc/os-release" ]] || return

    RELEASE_ID="$(source /etc/os-release && echo ${ID})"
    RELEASE_VERSION_CODENAME="$(source /etc/os-release && echo ${VERSION_CODENAME})"
    DOCKER_IMAGE_NAME=sf-${RELEASE_ID}-${RELEASE_VERSION_CODENAME}-${SF_CI_BREW_INSTALL}
    DOCKER_IMAGE_TAG=${GIT_HASH_SHORT}
    DOCKERFILE=${SUPPORT_FIRECLOUD_DIR}/ci/${OS_SHORT}/Dockerfile.${RELEASE_ID}.${RELEASE_VERSION_CODENAME}
    [[ -f "${DOCKERFILE}" ]] || return

    echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
    docker build . --file ${DOCKERFILE} --tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
    docker push ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
}

function ci_run_deploy() {
    [[ -z "${SF_DEPLOY_DOCKER_IMAGE:-}" ]] || ci_run_deploy_docker_image
}

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
