SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/Makefile.common.mk

PATH := $(MAKE_PATH)/node_modules/.bin:$(GIT_ROOT)/node_modules/.bin:$(PATH)
export PATH

ESLINT = $(call which,ESLINT,eslint)
NPM_PUBLISH_GIT = $(call which,NPM_PUBLISH_GIT,npm-publish-git)

ESLINT_ARGS ?= --ignore-pattern '!.eslintrc.js' --config $(MAKE_PATH)/node_modules/eslint-config-firecloud/no-ide.js

JS_FILES = $(shell $(GIT_LS) | $(GREP) -e ".js$$" | $(SED) "s/^/'/g" | $(SED) "s/$$/'/g")

SRC_JS_FILES := $(shell $(FIND_Q) src -type f -name "*.js" -print)
LIB_JS_FILES := $(patsubst src/%.js,lib/%.js,$(SRC_JS_FILES))

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	lib \
	node_modules \

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	build-js \

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	lint-js \

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


$(LIB_JS_FILES): lib/%.js: src/%.js $(SRC_JS_FILES)
	$(MKDIR) $(shell dirname $@)
	$(BABEL) $< --source-maps --out-file $@


.PHONY: build-js
build-js: $(LIB_JS_FILES)


.PHONY: lint-js
lint-js:
	$(ESLINT) $(ESLINT_ARGS) $(JS_FILES) || { \
		$(ESLINT) $(ESLINT_ARGS) --fix $(JS_FILES) 2>/dev/null >&2; \
		exit 1; \
	}


.PHONY: version
version: version/patch ## Bump version (patch level).


.PHONY: version/%
version/%: ## Bump version to given level (major/minor/patch).
	$(NPM) version ${*}


.PHONY: publish
publish: ## Publish as a git version tag.
	@$(ECHO_DO) "Publishing version..."
	$(NPM_PUBLISH_GIT)
	@$(ECHO_DONE)


.PHONY: publish/%
publish/%: ## Publish as given git tag.
	@$(ECHO_DO) "Publishing tag ${*}..."
	$(NPM_PUBLISH_GIT) --tag ${*}
	@$(ECHO_DONE)


.PHONY: package-json-prepare
ifneq (node_modules,$(shell basename $(abspath ..))) # let Makefile build, or else build runs twice
package-json-prepare:
	:
else # installing as dependency
package-json-prepare: build
endif
