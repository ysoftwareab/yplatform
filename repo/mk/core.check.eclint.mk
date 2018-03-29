EC_FILES_IGNORE := \
	-e "^$$" \
	$(VENDOR_FILES_IGNORE) \

EC_FILES = $(shell $(GIT_LS) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(EC_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	lint-ec \

ECLINT = $(call which,ECLINT,eclint)
ECLINT_ARGS ?=

# ------------------------------------------------------------------------------

.PHONY: lint-ec
lint-ec:
	[[ "$(words $(EC_FILES))" = "0" ]] || { \
		$(ECLINT) check $(ECLINT_ARGS) $(EC_FILES) || { \
			$(ECLINT) fix $(ECLINT_ARGS) $(EC_FILES) 2>/dev/null >&2; \
			exit 1; \
		}; \
	}
