ESLINT = $(call which,ESLINT,eslint)
ESLINT_ARGS ?=
ESLINT_ARGS := \
	$(ESLINT_ARGS) \
	--ignore-pattern '!.babelrc.js' \
	--ignore-pattern '!.eslintrc.js' \

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	lint-eslint \

# ------------------------------------------------------------------------------

.PHONY: lint-eslint
lint-eslint:
	[[ "$(words $(JS_FILES))" = "0" ]] || { \
		$(ESLINT) $(ESLINT_ARGS) $(JS_FILES) || { \
			$(ESLINT) $(ESLINT_ARGS) --fix $(JS_FILES) 2>/dev/null >&2; \
			exit 1; \
		}; \
	}
