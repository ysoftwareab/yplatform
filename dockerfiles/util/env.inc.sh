#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

export CI=true
export DEBIAN_FRONTEND=noninteractive
# export SF_DOCKER_CI_IMAGE_NAME= # --build-arg
# export SF_DOCKER_CI_IMAGE_TAG= # --build-arg
# export SF_CI_BREW_INSTALL= # --build-arg
GID_INDEX=999
UID_INDEX=999
GNAME=sf
UNAME=sf
