SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))

# ------------------------------------------------------------------------------

PATH := $(PATH):$(SUPPORT_FIRECLOUD_DIR)/bin
export PATH

CI_ECHO ?= $(SUPPORT_FIRECLOUD_DIR)/bin/ci-echo
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.inc.mk/Makefile

ifdef TRAVIS_BRANCH
GIT_BRANCH = $(TRAVIS_BRANCH)
endif

# makefile-folder node_modules exebutables
PATH_NPM := $(MAKE_PATH)/node_modules/.bin
# repository node_modules executables
PATH_NPM := $(PATH_NPM):$(GIT_ROOT)/node_modules/.bin

define npm-which
$(shell \
	export PATH="$(PATH_NPM):$(PATH)"; \
	export RESULT="$$(for CMD in $(2); do $(WHICH_Q) $${CMD} && break || continue; done)"; \
	echo "$${RESULT:-$(1)_NOT_FOUND}")
endef

SF_VENDOR_FILES_IGNORE := \
	-e "^$$" \
	-e "^LICENSE$$" \
	-e "^NOTICE$$" \
	-e "^UNLICENSE$$" \

SF_DEPS_TARGETS := \
	deps-git \

SF_BUILD_TARGETS := \

SF_CHECK_TARGETS := \

SF_TEST_TARGETS := \

# ------------------------------------------------------------------------------

.PHONY: all
all: deps build check ## Fetch dependencies, build and check.


include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.clean.mk


.PHONY: bootstrap
bootstrap: ## Bootstrap your system (skips common dependencies). Run 'make bootstrap/scratch' to include them.
	$(ECHO_DO) "Bootstrapping (skip common)..."
	SF_BREW_INSTALL_SKIP_COMMON=true $(SUPPORT_FIRECLOUD_DIR)/ci/$(OS_SHORT)/bootstrap
	$(ECHO_DONE)


.PHONY: bootstrap/scratch
bootstrap/scratch:
	$(ECHO_DO) "Bootstrapping..."
	$(SUPPORT_FIRECLOUD_DIR)/ci/$(OS_SHORT)/bootstrap
	$(ECHO_DONE)


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
test: ## Test.
	[[ "$(words $(SF_TEST_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Testing..."; \
		$(MAKE) $(SF_TEST_TARGETS); \
		$(ECHO_DONE); \
	}


.PHONY: support-firecloud/update
support-firecloud/update: ## Update support-firecloud to latest master commit.
	$(eval SF_SUBMODULE_PATH := $(shell $(GIT) config --file .gitmodules --get-regexp path | \
		$(GREP) $(shell basename $(SUPPORT_FIRECLOUD_DIR)) | $(CUT) -d' ' -f2))
	$(eval SF_COMMIT := $(shell $(GIT) rev-parse HEAD^{commit}:$(SF_SUBMODULE_PATH)))
	$(ECHO_DO) "Updating $(SF_SUBMODULE_PATH)..."
	$(GIT) submodule update --init --recursive --remote $(SF_SUBMODULE_PATH)
	$(GIT) add $(SF_SUBMODULE_PATH)
	$(GIT) commit -m "updated $(SF_SUBMODULE_PATH)"
	$(GIT) submodule update --init --recursive $(SF_SUBMODULE_PATH)
	$(ECHO)
	$(ECHO_INFO) "Changes in $(SF_SUBMODULE_PATH) since $(SF_COMMIT):"
	$(ECHO)
	$(GIT) -C $(SF_SUBMODULE_PATH) --no-pager log \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(SF_COMMIT).. | \
		$(GREP) --color -E "^|break"
	$(ECHO)
	$(GIT) -C $(SF_SUBMODULE_PATH) --no-pager \
		diff --stat $(SF_COMMIT)..
	$(ECHO)
	$(ECHO_DONE)
