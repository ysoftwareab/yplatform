ECLINT = $(call which,ECLINT,eclint)
ECLINT_ARGS ?=

SF_ECLINT_FILES_IGNORE := \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \

SF_ECLINT_FILES = $(shell $(GIT_LS) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_ECLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	lint-eclint \

# ------------------------------------------------------------------------------

.PHONY: lint-eclint
lint-eclint:
	[[ "$(words $(SF_ECLINT_FILES))" = "0" ]] || { \
		$(ECLINT) check $(ECLINT_ARGS) $(SF_ECLINT_FILES) || { \
			$(ECLINT) fix $(ECLINT_ARGS) $(SF_ECLINT_FILES) 2>/dev/null >&2; \
			exit 1; \
		}; \
	}
