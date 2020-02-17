# Adds a 'docker-ci' target to start a local docker-ci container.
#
# The docker image that is used by the docker-ci container can be adjusted by
# setting SF_TRAVIS_DOCKER_IMAGE to another image available on the Docker Hub Registry.
#
# NOTE SF_TRAVIS_DOCKER_IMAGE should be in sync with SF_TRAVIS_DOCKER_IMAGE in .ci.sh
# or any other CI configuration that sets the docker image.
#
# TODO ideally the duplication in Makefile and .ci.sh of SF_TRAVIS_DOCKER_IMAGE
# should not exist, but switching to a CI with native docker integration,
# is going to prove even harder to deduplicate. Rather than focus on deduplication,
# an alternative is to have a check that the image is the same in all places.
#
# ------------------------------------------------------------------------------

SF_TRAVIS_DOCKER_IMAGE ?= tobiipro/sf-ubuntu-xenial-minimal

# ------------------------------------------------------------------------------

.PHONY: docker-ci
docker-ci:
	$(eval CONTAINER_NAME := $(shell echo "sf-docker-ci-$$(basename $(PWD))"))
	source $(SUPPORT_FIRECLOUD_DIR)/sh/common.inc.sh && \
		source $(SUPPORT_FIRECLOUD_DIR)/repo/ci.sh/before-install.pre.inc.sh && \
		sf_run_travis_docker_image $(SF_TRAVIS_DOCKER_IMAGE) $(CONTAINER_NAME) $(PWD)
	$(ECHO) "[WARN] Make sure to export relevant environment variables!"
	$(ECHO) "       e.g. secrets in the web UI of Travis CI."
	docker exec -it -w $(PWD) -u $$(id -u):$$(id -g) $(CONTAINER_NAME) ./.ci.sh debug || true
	docker kill $(CONTAINER_NAME)
