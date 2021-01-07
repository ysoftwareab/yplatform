FROM ubuntu:16.04

SHELL ["/bin/bash", "-c"]

ADD . /support-firecloud
RUN /support-firecloud/.codeship/$(source /etc/os-release && echo "${ID}-${VERSION_ID}")/Dockerfile.build.sh
ADD . /home/codeship/build
RUN chown -R codeship:codeship /home/codeship/build

USER codeship
WORKDIR /home/codeship/build
