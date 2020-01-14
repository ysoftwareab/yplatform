ARG FROM
FROM ${FROM}

ARG IMAGE_TAG
ARG SF_CI_BREW_INSTALL

ADD . /support-firecloud
RUN IMAGE_TAG=${IMAGE_TAG} \
    SF_CI_BREW_INSTALL=${SF_CI_BREW_INSTALL} \
    /support-firecloud/dockerfiles/ubuntu-$(source /etc/os-release && echo ${VERSION_CODENAME})/script.sh
