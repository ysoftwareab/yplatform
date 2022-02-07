# Adds a 'docker-ci' target to start a local docker-ci container.
#
# The docker image that is used by the docker-ci container can be adjusted by
# setting YP_DOCKER_CI_IMAGE to another image available on the Docker Hub Registry.
# By default, YP_DOCKER_CI_IMAGE is the same as for the .ci.sh script.
#
# ------------------------------------------------------------------------------

YP_DOCKER_CI_IMAGE ?= $(shell source $(GIT_ROOT)/.ci.sh 2>/dev/null && yp_get_docker_ci_image)
YP_DOCKER_CI_IMAGE_DEFAULT ?= ysoftwareab/yp-ubuntu-20.04-minimal:$(YP_VSN)

ifeq (,$(patsubst ysoftwareab/yp-macos-%,,$(YP_DOCKER_CI_IMAGE)))
$(warn [WARN] Using default docker-ci image $(YP_DOCKER_CI_IMAGE_DEFAULT).)
YP_DOCKER_CI_IMAGE = $(YP_DOCKER_CI_IMAGE_DEFAULT)
endif

DOCKER = $(call which,DOCKER,docker)
$(foreach VAR,DOCKER,$(call make-lazy-once,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: docker-ci
docker-ci: ## Start a Docker CI container (mount entire project).
	$(eval CONTAINER_NAME := $(shell $(ECHO) "yp-docker-ci-$$(basename $${PWD})"))
	$(DOCKER) kill $(CONTAINER_NAME) || true
	source $(YP_DIR)/sh/common.inc.sh && \
		source $(YP_DIR)/ci/util/docker-ci.inc.sh && \
		yp_run_docker_ci_image $(YP_DOCKER_CI_IMAGE) $${PWD} $(CONTAINER_NAME)
	$(ECHO) "[WARN] Make sure to export relevant environment variables!"
	$(DOCKER) exec -it \
		--env YP_SKIP_SUDO_BOOTSTRAP=true \
		--env YP_SKIP_BREW_BOOTSTRAP=true \
		--workdir $${PWD} \
		--user $$(id -u):$$(id -g) \
		$(CONTAINER_NAME) \
		/yplatform/bin/ci-debug || true
	$(DOCKER) kill $(CONTAINER_NAME)


.PHONY: docker-ci/git
docker-ci/git: ## Start a Docker CI container (mount only git-dir).
	$(eval CONTAINER_NAME := $(shell $(ECHO) "yp-docker-ci-git-$$(basename $${PWD})"))
	$(DOCKER) kill $(CONTAINER_NAME) || true
	source $(YP_DIR)/sh/common.inc.sh && \
		source $(YP_DIR)/ci/util/docker-ci.inc.sh && \
		yp_run_docker_ci_image $(YP_DOCKER_CI_IMAGE) $${PWD}/.git $(CONTAINER_NAME)
	$(ECHO) "[WARN] Make sure to export relevant environment variables!"
	$(DOCKER) exec -it \
		--env YP_SKIP_BREW_BOOTSTRAP=true \
		--env YP_SKIP_SUDO_BOOTSTRAP=true \
		--workdir $${PWD} \
		--user $$(id -u):$$(id -g) \
		$(CONTAINER_NAME) \
		/yplatform/bin/ci-debug "git checkout . && bash" || true
	$(DOCKER) kill $(CONTAINER_NAME)
