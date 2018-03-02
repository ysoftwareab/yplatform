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
LIB_JS_FILES := $(patsubst src/%.js,lib/%.js,$(SRC_JS_FILES))

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	lib \
	node_modules \

BABELRC := $(shell $(FIND_Q) . -mindepth 0 -maxdepth 1 -name ".babelrc*" -print)

# ------------------------------------------------------------------------------

.PHONY: all
all: deps build check ## Fetch dependencies, build and check.


.PHONY: deps-npm
deps-npm:
	$(NPM) install --no-package-lock
	if [[ -x node_modules/babel-preset-firecloud/npm-install-peer-dependencies ]]; then \
		node_modules/babel-preset-firecloud/npm-install-peer-dependencies; \
	fi
	if [[ -x node_modules/eslint-config-firecloud/npm-install-peer-dependencies ]]; then \
		node_modules/eslint-config-firecloud/npm-install-peer-dependencies; \
	fi


.PHONY: deps
deps: ## Fetch dependencies.
	@$(ECHO_DO) "Fetching dependencies..."
	$(MAKE) deps-git deps-npm
	@$(ECHO_DONE)

.PHONY: version
version: version/patch ## Bump version (patch level).


.PHONY: version/%
version/%: ## Bump version to given level (major/minor/patch).
	$(NPM) version $*
