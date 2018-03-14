SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/generic.common.mk

PATH := $(MAKE_PATH)/node_modules/.bin:$(GIT_ROOT)/node_modules/.bin:$(PATH)
export PATH

EC_FILES_IGNORE := \
	$(EC_FILES_IGNORE) \
	-e "^package-lock.json$$" \

JS_FILES_IGNORE := \
	-e "^$$"

JS_FILES = $(shell $(GIT_LS) | \
	$(GREP) -v $(JS_FILES_IGNORE) | \
	$(GREP) -e ".js$$" | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SRC_JS_FILES := $(shell $(FIND_Q) src -type f -name "*.js" -print)

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	node_modules \

SF_DEPS_TARGETS := \
	$(SF_DEPS_TARGETS) \
	deps-npm \

# ------------------------------------------------------------------------------

.PHONY: all
all: deps build check ## Fetch dependencies, build and check.


.PHONY: deps-npm
deps-npm:
	$(eval NPM_LOGS_DIR := $(shell $(NPM) config get cache)/_logs)
	$(NPM) install || { \
		$(CAT) $(NPM_LOGS_DIR)/`ls -t $(NPM_LOGS_DIR) | $(HEAD) -1` | \
			$(GREP) -q "No matching version found for" && \
			$(NPM) install; \
	}
	if [[ -x node_modules/babel-preset-firecloud/npm-install-peer-dependencies ]]; then \
		node_modules/babel-preset-firecloud/npm-install-peer-dependencies; \
	fi
	if [[ -x node_modules/eslint-config-firecloud/npm-install-peer-dependencies ]]; then \
		node_modules/eslint-config-firecloud/npm-install-peer-dependencies; \
	fi


.PHONY: version
version: version/patch ## Bump version (patch level).


.PHONY: version/%
version/%: ## Bump version to given level (major/minor/patch).
	@$(ECHO_DO) "Bumping $* version..."
	$(NPM) version $*
	@$(ECHO_DONE)
