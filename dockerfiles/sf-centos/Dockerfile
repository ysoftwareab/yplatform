ARG SF_DOCKER_CI_FROM
FROM ${SF_DOCKER_CI_FROM}

ARG SF_CI_BREW_INSTALL
ARG SF_DOCKER_CI_IMAGE_NAME
ARG SF_DOCKER_CI_IMAGE_TAG
ARG SF_OS_RELEASE_DIR

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

COPY . /support-firecloud

# see https://www.camptocamp.com/en/news-events/flexible-docker-entrypoints-scripts
# see https://github.com/camptocamp/docker-git/blob/master/docker-entrypoint.sh
RUN cp -Rp -L /support-firecloud/${SF_OS_RELEASE_DIR}/Dockerfile.entrypoint.sh /Dockerfile.entrypoint.sh
RUN cp -Rp -L /support-firecloud/${SF_OS_RELEASE_DIR}/Dockerfile.entrypoint.d /Dockerfile.entrypoint.d
# ONBUILD COPY Dockerfile.entrypoint.d/* /Dockerfile.entrypoint.d/
# ONBUILD COPY docker-entrypoint.d/* /Dockerfile.entrypoint.d/ # ?! compat with camptocamp
ENTRYPOINT ["/Dockerfile.entrypoint.sh"]

RUN SF_DOCKER_CI_IMAGE_NAME=${SF_DOCKER_CI_IMAGE_NAME} \
  SF_DOCKER_CI_IMAGE_TAG=${SF_DOCKER_CI_IMAGE_TAG} \
  SF_CI_BREW_INSTALL=${SF_CI_BREW_INSTALL} \
  /support-firecloud/dockerfiles/$(source /etc/os-release && echo "sf-${ID}-${VERSION_ID}")/Dockerfile.build.sh

CMD ["bash"]
