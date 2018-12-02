ESLINT = $(call which,ESLINT,eslint)
$(foreach VAR,ESLINT,$(call make-lazy,$(VAR)))

ESLINT_ARGS ?=
ESLINT_ARGS := \
	$(ESLINT_ARGS) \
	--ignore-pattern '!.babelrc.js' \
	--ignore-pattern '!.eslintrc.js' \

SF_ESLINT_FILES_IGNORE := \
	-e "^$$"

SF_ESLINT_FILES = $(shell $(GIT_LS) . | \
	$(GREP) -v $(SF_ESLINT_FILES_IGNORE) | \
	$(GREP) -e "\.js$$" | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	lint-eslint \

# ------------------------------------------------------------------------------

.PHONY: lint-eslint
lint-eslint:
	[[ "$(words $(SF_ESLINT_FILES))" = "0" ]] || { \
		$(ESLINT) $(ESLINT_ARGS) $(SF_ESLINT_FILES) || { \
			$(ESLINT) $(ESLINT_ARGS) --fix $(SF_ESLINT_FILES) 2>/dev/null >&2; \
			exit 1; \
		}; \
	}
