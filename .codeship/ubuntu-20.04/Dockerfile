FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

ADD . /support-firecloud
RUN SF_DOCKER_CI_IMAGE_NAME=sf-$(source /etc/os-release && echo "${ID}-${VERSION_ID}") \
  SF_DOCKER_CI_IMAGE_TAG=codeship \
  /support-firecloud/.codeship/$(source /etc/os-release && echo "${ID}-${VERSION_ID}")/Dockerfile.build.sh
ADD . /home/codeship/build
RUN chown -R codeship:codeship /home/codeship/build

USER codeship
WORKDIR /home/codeship/build
