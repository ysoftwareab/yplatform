# Adds a 'docker-ci' target to start a local docker-ci container.
#
# The docker image that is used by the docker-ci container can be adjusted by
# setting SF_DOCKER_CI_IMAGE to another image available on the Docker Hub Registry.
# By default, SF_DOCKER_CI_IMAGE is the same as for the .ci.sh script.
#
# ------------------------------------------------------------------------------

ifeq (linux,$(OS_SHORT))
SF_DOCKER_CI_IMAGE ?= $(shell source $(GIT_ROOT)/.ci.sh && sf_get_docker_ci_image 2>/dev/null)
else
SF_DOCKER_CI_IMAGE ?= rokmoln/sf-ubuntu-xenial-minimal
endif

# ------------------------------------------------------------------------------

.PHONY: docker-ci
docker-ci:
	$(eval CONTAINER_NAME := $(shell echo "sf-docker-ci-$$(basename $(PWD))"))
	source $(SUPPORT_FIRECLOUD_DIR)/sh/common.inc.sh && \
		source $(SUPPORT_FIRECLOUD_DIR)/ci/run.docker-ci.inc.sh && \
		sf_run_docker_ci_image $(SF_DOCKER_CI_IMAGE) $(PWD) $(CONTAINER_NAME)
	$(ECHO) "[WARN] Make sure to export relevant environment variables!"
	docker exec -it -w $(PWD) -u $$(id -u):$$(id -g) $(CONTAINER_NAME) ./.ci.sh debug || true
	docker kill $(CONTAINER_NAME)
