#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

export CI=true
# export SF_DOCKER_CI_IMAGE_NAME= # --build-arg
# export SF_DOCKER_CI_IMAGE_TAG= # --build-arg
# export SF_CI_BREW_INSTALL= # --build-arg
GID_INDEX=999
UID_INDEX=999
GNAME=sf
UNAME=sf
GIT_USER_EMAIL="${SF_DOCKER_CI_IMAGE_NAME}.${SF_DOCKER_CI_IMAGE_TAG}@docker"
GIT_USER_NAME="${SF_DOCKER_CI_IMAGE_NAME} ${SF_DOCKER_CI_IMAGE_TAG}"

[[ ! -e ${SUPPORT_FIRECLOUD_DIR}/sf-ci-echo-benchmark ]] || \
    export SF_CI_ECHO_BENCHMARK=${SUPPORT_FIRECLOUD_DIR}/sf-ci-echo-benchmark
