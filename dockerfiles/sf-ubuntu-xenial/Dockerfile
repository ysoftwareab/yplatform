ARG FROM
FROM ${FROM}

ARG IMAGE_TAG
ARG SF_CI_BREW_INSTALL

SHELL ["/bin/bash", "-c"]

ADD . /support-firecloud
RUN IMAGE_TAG=${IMAGE_TAG} \
    SF_CI_BREW_INSTALL=${SF_CI_BREW_INSTALL} \
    /support-firecloud/dockerfiles/$(source /etc/os-release && echo "${RELEASE_ID}-${VERSION_CODENAME}")/script.sh
