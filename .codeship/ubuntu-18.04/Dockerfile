# syntax=docker/dockerfile:1
FROM ubuntu:16.04

SHELL ["/bin/bash", "-c"]

ADD . /yplatform
RUN YP_DOCKER_CI_IMAGE_NAME=sf-$(source /etc/os-release && echo "${ID}-${VERSION_ID}") \
    YP_DOCKER_CI_IMAGE_TAG=codeship \
    /yplatform/.codeship/$(source /etc/os-release && echo "${ID}-${VERSION_ID}")/Dockerfile.build.sh
ADD . /home/codeship/build
RUN chown -R codeship:codeship /home/codeship/build

USER codeship
WORKDIR /home/codeship/build
