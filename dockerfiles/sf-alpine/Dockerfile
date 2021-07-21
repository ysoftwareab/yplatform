ARG SF_DOCKER_CI_FROM
FROM ${SF_DOCKER_CI_FROM}

ARG SF_DOCKER_CI_IMAGE_NAME
ARG SF_DOCKER_CI_IMAGE_TAG
ARG SF_CI_BREW_INSTALL

RUN apk add --no-cache bash
ENV LD_LIBRARY_PATH=/usr/glibc-compat/lib
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

COPY . /support-firecloud
RUN SF_DOCKER_CI_IMAGE_NAME=${SF_DOCKER_CI_IMAGE_NAME} \
    SF_DOCKER_CI_IMAGE_TAG=${SF_DOCKER_CI_IMAGE_TAG} \
    SF_CI_BREW_INSTALL=${SF_CI_BREW_INSTALL} \
    /support-firecloud/dockerfiles/$(source /etc/os-release && echo "sf-${ID}-${VERSION_ID}")/Dockerfile.build.sh
