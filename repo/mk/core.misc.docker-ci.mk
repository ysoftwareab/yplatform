# Adds a 'docker-ci' target to start a local docker-ci container.
#
# The docker image that is used by the docker-ci container can be adjusted by
# setting SF_DOCKER_CI_IMAGE to another image available on the Docker Hub Registry.
# By default, SF_DOCKER_CI_IMAGE is the same as for the .ci.sh script.
#
# ------------------------------------------------------------------------------

SF_DOCKER_CI_IMAGE ?= $(shell source $(GIT_ROOT)/.ci.sh && sf_get_docker_ci_image)

# ------------------------------------------------------------------------------

.PHONY: docker-ci
docker-ci:
	$(eval CONTAINER_NAME := $(shell echo "sf-docker-ci-$$(basename $(PWD))"))
	source $(SUPPORT_FIRECLOUD_DIR)/sh/common.inc.sh && \
		source $(SUPPORT_FIRECLOUD_DIR)/repo/ci.sh/before-install.pre.inc.sh && \
		sf_run_docker_ci_image $(SF_DOCKER_CI_IMAGE) $(CONTAINER_NAME) $(PWD)
	$(ECHO) "[WARN] Make sure to export relevant environment variables!"
	$(ECHO) "       e.g. secrets in the web UI of Travis CI."
	docker exec -it -w $(PWD) -u $$(id -u):$$(id -g) $(CONTAINER_NAME) ./.ci.sh debug || true
	docker kill $(CONTAINER_NAME)
