#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

export CI=true
# export YP_DOCKER_CI_IMAGE_NAME= # --build-arg
# export YP_DOCKER_CI_IMAGE_TAG= # --build-arg
# export YP_CI_BREW_INSTALL= # --build-arg
GID_INDEX=999
UID_INDEX=999
GNAME=sf
UNAME=sf
GIT_USER_EMAIL="${YP_DOCKER_CI_IMAGE_NAME}.${YP_DOCKER_CI_IMAGE_TAG}@docker"
GIT_USER_NAME="${YP_DOCKER_CI_IMAGE_NAME} ${YP_DOCKER_CI_IMAGE_TAG}"

[[ ! -e ${SUPPORT_FIRECLOUD_DIR}/sf-ci-echo-benchmark ]] || \
    export YP_CI_ECHO_BENCHMARK=${SUPPORT_FIRECLOUD_DIR}/sf-ci-echo-benchmark
