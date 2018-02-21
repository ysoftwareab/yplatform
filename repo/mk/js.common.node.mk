SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/generic.common.mk

PATH := $(MAKE_PATH)/node_modules/.bin:$(GIT_ROOT)/node_modules/.bin:$(PATH)
export PATH

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

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	build-js \

BABEL_RC := $(shell $(FIND_Q) . -mindepth 0 -maxdepth 1 -name ".babelrc*" -print)

# ------------------------------------------------------------------------------

.PHONY: all
all: deps build check ## Fetch dependencies, build and check.


.PHONY: deps-npm
deps-npm:
	$(NPM) install --no-package-lock
	node_modules/babel-preset-firecloud/npm-install-peer-dependencies
	node_modules/eslint-config-firecloud/npm-install-peer-dependencies


.PHONY: deps
deps: ## Fetch dependencies.
	@$(ECHO_DO) "Fetching dependencies..."
	$(MAKE) deps-git deps-npm
	@$(ECHO_DONE)


$(LIB_JS_FILES): lib/%.js: src/%.js $(SRC_JS_FILES) $(BABEL_RC)
	$(MKDIR) $(shell dirname $@)
	$(BABEL) $< --source-maps --out-file $@


.PHONY: build-js
build-js: $(LIB_JS_FILES)


.PHONY: version
version: version/patch ## Bump version (patch level).


.PHONY: version/%
version/%: ## Bump version to given level (major/minor/patch).
	$(NPM) version ${*}
