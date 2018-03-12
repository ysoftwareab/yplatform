# Usage:

# ifeq (,$(wildcard support-firecloud/Makefile))
# INSTALL_SUPPORT_FIRECLOUD := $(shell git submodule update --init --recursive support-firecloud)
# ifneq (,$(filter undefine,$(.FEATURES)))
# undefine INSTALL_SUPPORT_FIRECLOUD
# endif
# endif

# include support-firecloud/repo/mk/generic.common.mk
# include support-firecloud/repo/mk/...

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.inc.mk/Makefile

TRAVIS ?=
ifeq (true,$(TRAVIS))
GIT_BRANCH = $(TRAVIS_BRANCH)
endif

CI_ECHO = $(SUPPORT_FIRECLOUD_DIR)/bin/ci-echo
ECLINT = $(call which,ECLINT,eclint)
ECLINT_ARGS ?=
JSONLINT = $(SUPPORT_FIRECLOUD_DIR)/bin/jsonlint

IS_TRANSCRYPTED := $(shell $(GIT) config --local transcrypted.version >/dev/null && echo true || echo false)

EC_FILES_IGNORE := \
	-e "^LICENSE$$" \
	-e "^UNLICENSE$$" \

EC_FILES = $(shell $(GIT_LS) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(EC_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

JSON_FILES = $(shell $(GIT_LS) | \
	$(GREP) -e ".json$$" | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CLEAN_FILES := \

SF_BUILD_TARGETS :=

SF_CHECK_TARGETS := \
	lint-ec \
	lint-json \

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


.PHONY: build
build: ## Build.
	[[ "$(words $(SF_BUILD_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Building..."; \
		$(MAKE) $(SF_BUILD_TARGETS); \
		$(ECHO_DONE); \
	}


.PHONY: lint-ec
lint-ec:
	[[ "$(words $(EC_FILES))" = "0" ]] || { \
		$(ECLINT) check $(ECLINT_ARGS) $(EC_FILES) || { \
			$(ECLINT) fix $(ECLINT_ARGS) $(EC_FILES) 2>/dev/null >&2; \
			exit 1; \
		}; \
	}


.PHONY: lint-json
lint-json:
	[[ "$(words $(JSON_FILES))" = "0" ]] || { \
		$(JSONLINT) $(JSON_FILES); \
	}


.PHONY: check
check: ## Check.
	[[ "$(words $(SF_CHECK_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Checking..."; \
		$(MAKE) $(SF_CHECK_TARGETS); \
		$(ECHO_DONE); \
	}


.PHONY: test
test: check ## Check and test.
	[[ "$(words $(SF_TEST_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Testing..."; \
		$(MAKE) $(SF_TEST_TARGETS); \
		$(ECHO_DONE); \
	}


.PHONY: support-firecloud/update
support-firecloud/update: ## Update support-firecloud to latest master commit.
	cd support-firecloud; \
		$(GIT) fetch; \
		$(GIT) checkout -f origin/master
	$(GIT) add support-firecloud
	$(GIT) commit -m "updated support-firecloud"


.PHONY: release
release: release/patch ## Release a new version (patch level).


.PHONY: release/%
release/%: ## Release a new version with given level (major/minor/patch).
	@$(ECHO_DO) "Release new $* version..."
	$(MAKE) nuke all test version/$* publish
	$(GIT) push
	@$(ECHO_DONE)
