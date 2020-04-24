FROM ubuntu:16.04

SHELL ["/bin/bash", "-c"]

ADD . /build
RUN /build/.codeship/$(source /etc/os-release && echo "${ID}-${VERSION_CODENAME}")/script.sh
RUN mv /build /home/codeship/build
RUN chown -R codeship:codeship /home/codeship/build

USER codeship
WORKDIR /home/codeship/build
