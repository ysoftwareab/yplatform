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

CI_ECHO = $(SUPPORT_FIRECLOUD_DIR)/bin/ci-echo
ECLINT = $(call which,ECLINT,eclint)
ECLINT_ARGS ?=
JSONLINT = $(call which,JSONLINT,jsonlint)

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

SF_CLEAN_FILES :=

SF_BUILD_TARGETS :=

SF_CHECK_TARGETS := \
	lint-ec \
	lint-json \

SF_TEST_TARGETS := \

# ------------------------------------------------------------------------------

.PHONY: clean
clean: ## Clean.
	@$(ECHO_DO) "Cleaning..."
	$(RM) $(SF_CLEAN_FILES)
	@$(ECHO_DONE)


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
ifneq (0,$(words $(SF_CHECK_TARGETS)))
build: ## Build.
	@$(ECHO_DO) "Building..."
	$(MAKE) $(SF_BUILD_TARGETS)
	@$(ECHO_DONE)
else
build:
	:
endif


.PHONY: lint-ec
lint-ec:
	$(ECLINT) check $(ECLINT_ARGS) $(EC_FILES) || { \
		$(ECLINT) fix $(ECLINT_ARGS) $(EC_FILES) 2>/dev/null >&2; \
		exit 1; \
	}


.PHONY: lint-json
ifneq (0,$(words $(JSON_FILES)))
lint-json:
	for f in $(JSON_FILES); do \
		$(JSON) -q --validate -f "$${f}"; \
	done
else
lint-json:
	:
endif


.PHONY: check
ifneq (0,$(words $(SF_CHECK_TARGETS)))
check: ## Check.
	@$(ECHO_DO) "Checking..."
	$(MAKE) $(SF_CHECK_TARGETS)
	@$(ECHO_DONE)
else
check:
	:
endif


.PHONY: test
ifneq (0,$(words $(SF_TEST_TARGETS)))
test: check ## Test.
	@$(ECHO_DO) "Testing..."
	$(MAKE) $(SF_TEST_TARGETS)
	@$(ECHO_DONE)
else
test:
	:
endif
