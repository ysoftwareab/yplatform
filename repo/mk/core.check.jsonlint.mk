JSONLINT = $(SUPPORT_FIRECLOUD_DIR)/bin/jsonlint
SF_IS_TRANSCRYPTED ?= false

SF_JSONLINT_FILES_IGNORE := \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \

SF_JSONLINT_FILES = $(shell $(GIT_LS) . | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -Fvxf <([ $(SF_IS_TRANSCRYPTED) ] || [ ! -x $(TOP)/transcrypt ] || $(TOP)/transcrypt -l) | \
	$(GREP) -e ".json$$" | \
	$(GREP) -v $(SF_JSONLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	lint-jsonlint \

# ------------------------------------------------------------------------------

.PHONY: lint-jsonlint
lint-jsonlint:
	[[ "$(words $(SF_JSONLINT_FILES))" = "0" ]] || { \
		$(JSONLINT) $(SF_JSONLINT_FILES); \
	}
