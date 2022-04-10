# syntax=docker/dockerfile:1
ARG YP_DOCKER_CI_FROM
FROM ${YP_DOCKER_CI_FROM}

LABEL maintainer="mejla@software.se"
LABEL vendor="Y Software AB"
LABEL url="https://github.com/ysoftwareab/yplatform"
LABEL vcs-url="https://github.com/ysoftwareab/yplatform"
ARG YP_LABEL_VCS_REF="0"
LABEL vcs-ref=${YP_LABEL_VCS_REF}
ARG YP_LABEL_BUILD_DATE="1970-01-01T00:00:00Z"
LABEL build-date=${YP_LABEL_BUILD_DATE}

ARG YP_CI_BREW_INSTALL
ARG YP_DOCKER_CI_IMAGE_NAME
ARG YP_OS_RELEASE_DIR

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

COPY . /yplatform

RUN cp -Rp -L /yplatform/${YP_OS_RELEASE_DIR}/Dockerfile.test.sh /Dockerfile.test.sh
# see https://www.camptocamp.com/en/news-events/flexible-docker-entrypoints-scripts
# see https://github.com/camptocamp/docker-git/blob/master/docker-entrypoint.sh
RUN cp -Rp -L /yplatform/${YP_OS_RELEASE_DIR}/Dockerfile.entrypoint.sh /Dockerfile.entrypoint.sh
RUN cp -Rp -L /yplatform/${YP_OS_RELEASE_DIR}/Dockerfile.entrypoint.d /Dockerfile.entrypoint.d
# ONBUILD COPY Dockerfile.entrypoint.d/* /Dockerfile.entrypoint.d/
# ONBUILD COPY docker-entrypoint.d/* /Dockerfile.entrypoint.d/ # ?! compat with camptocamp
ENTRYPOINT ["/Dockerfile.entrypoint.sh"]

RUN YP_DOCKER_CI_IMAGE_NAME=${YP_DOCKER_CI_IMAGE_NAME} \
  YP_CI_BREW_INSTALL=${YP_CI_BREW_INSTALL} \
  /yplatform/${YP_OS_RELEASE_DIR}/Dockerfile.build.sh

CMD ["bash"]
