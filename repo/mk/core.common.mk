SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.inc.mk/Makefile

ifdef TRAVIS_BRANCH
GIT_BRANCH = $(TRAVIS_BRANCH)
endif

CI_ECHO := $(SUPPORT_FIRECLOUD_DIR)/bin/ci-echo

SF_VENDOR_FILES_IGNORE := \
	-e "^$$" \
	-e "^LICENSE$$" \
	-e "^NOTICE$$" \
	-e "^UNLICENSE$$" \

SF_CLEAN_FILES := \

SF_DEPS_TARGETS := \
	deps-git \

SF_BUILD_TARGETS := \

SF_CHECK_TARGETS := \

SF_TEST_TARGETS := \

# ------------------------------------------------------------------------------

.PHONY: all
all: deps build check ## Fetch dependencies, build and check.


.PHONY: clean
clean: ## Clean.
	[[ "$(words $(SF_CLEAN_FILES))" = "0" ]] || { \
		$(ECHO_DO) "Cleaning..."; \
		$(RM) $(SF_CLEAN_FILES); \
		$(ECHO_DONE); \
	}


.PHONY: nuke
nuke: ## Nuke (Stash actually) all files/changes not checked in.
	@$(ECHO_DO) "Nuking..."
	$(GIT) reset
	$(GIT) stash --all
	@$(ECHO_DONE)


.PHONY: deps-git
deps-git:
	$(GIT) submodule sync
	$(GIT) submodule update --init --recursive


.PHONY: deps
deps: ## Fetch dependencies.
	[[ "$(words $(SF_DEPS_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Fetching dependencies..."; \
		$(MAKE) $(SF_DEPS_TARGETS); \
		$(ECHO_DONE); \
	}


.PHONY: build
build: ## Build.
	[[ "$(words $(SF_BUILD_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Building..."; \
		$(MAKE) $(SF_BUILD_TARGETS); \
		$(ECHO_DONE); \
	}


.PHONY: check
check: ## Check.
	[[ "$(words $(SF_CHECK_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Checking..."; \
		$(MAKE) $(SF_CHECK_TARGETS); \
		$(ECHO_DONE); \
	}


.PHONY: test
test: ## Test and check.
	[[ "$(words $(SF_TEST_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Testing..."; \
		$(MAKE) $(SF_TEST_TARGETS); \
		$(ECHO_DONE); \
	}
	$(MAKE) check


.PHONY: support-firecloud/update
support-firecloud/update: ## Update support-firecloud to latest master commit.
	$(GIT) submodule update --init --recursive --remote support-firecloud
	$(GIT) add support-firecloud
	$(GIT) commit -m "updated support-firecloud"
	$(GIT) submodule update --init --recursive support-firecloud
