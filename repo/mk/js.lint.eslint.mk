ESLINT = $(call which,ESLINT,eslint)
ESLINT_ARGS ?= \
	--ignore-pattern '!.babelrc.js' \
	--ignore-pattern '!.eslintrc.js' \
	--config $(MAKE_PATH)/node_modules/eslint-config-firecloud/no-ide.js \

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	lint-js \

# ------------------------------------------------------------------------------

.PHONY: lint-js
lint-js:
	$(ESLINT) $(ESLINT_ARGS) $(JS_FILES) || { \
		$(ESLINT) $(ESLINT_ARGS) --fix $(JS_FILES) 2>/dev/null >&2; \
		exit 1; \
	}
