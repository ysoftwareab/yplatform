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
	-e "^$$" \
	-e "^LICENSE$$" \
	-e "^UNLICENSE$$" \

EC_FILES = $(shell $(GIT_LS) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(EC_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

JSON_FILES_IGNORE := \
	-e "^$$" \

JSON_FILES = $(shell $(GIT_LS) | \
	$(GREP) -e ".json$$" | \
	$(GREP) -v $(JSON_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CLEAN_FILES := \

SF_DEPS_TARGETS := \
	deps-git \

SF_BUILD_TARGETS := \

SF_CHECK_TARGETS := \
	lint-ec \
	lint-json \

SF_TEST_TARGETS := \

SNAPSHOT_DIR := snapshot.dir
SNAPSHOT_ZIP := snapshot.zip
SNAPSHOT_GIT_HASH := .git_hash

SNAPSHOT_FILES_IGNORE := \
	-e "^$(SNAPSHOT_DIR)/" \
	-e "^$(SNAPSHOT_ZIP)$$" \

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


.PHONY: snapshot
snapshot: ## Create a zip snapshot of all the git content that is not tracked.
	@$(ECHO_DO) "Creating $(SNAPSHOT_ZIP)..."
	$(RM) $(SNAPSHOT_DIR)
	$(MKDIR) $(SNAPSHOT_DIR)
	for f in `$(GIT_LS_SUB)` `$(GIT_LS_NEW) | $(GREP) -v $(SNAPSHOT_FILES_IGNORE)`; do \
		$(CP) --parents $${f} $(SNAPSHOT_DIR)/; \
	done
	$(ECHO) -n "$(GIT_HASH)" > $(SNAPSHOT_DIR)/$(SNAPSHOT_GIT_HASH)
	cd $(SNAPSHOT_DIR) && $(ZIP) -q $(GIT_ROOT)/$(SNAPSHOT_ZIP) * .*
	@$(ECHO_DONE)


.PHONY: reset-to-snapshot
reset-to-snapshot: ## Reset codebase to the contents of the zip snapshot.
	@$(ECHO_DO) "Resetting to $(SNAPSHOT_ZIP)..."
	$(UNZIP) $(SNAPSHOT_ZIP) $(SNAPSHOT_GIT_HASH)
	$(GIT) reset --hard `$(CAT) ${SNAPSHOT_GIT_HASH}`
	$(GIT) reset --soft $(GIT_HASH_SHORT)
	$(GIT) clean -xdf -e $(SNAPSHOT_ZIP) -- .
	$(GIT) reset
	$(UNZIP) -q snapshot.zip
	@$(ECHO_DONE)


.PHONY: support-firecloud/update
support-firecloud/update: ## Update support-firecloud to latest master commit.
	cd support-firecloud; \
		$(GIT) fetch; \
		$(GIT) checkout -f origin/master
	$(GIT) add support-firecloud
	$(GIT) commit -m "updated support-firecloud"
