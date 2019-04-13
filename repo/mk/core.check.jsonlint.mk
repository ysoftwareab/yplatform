JSONLINT = $(SUPPORT_FIRECLOUD_DIR)/bin/jsonlint
SF_IS_TRANSCRYPTED ?= false

SF_JSONLINT_FILES_IGNORE := \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \

SF_JSONLINT_FILES = $(shell $(GIT_LS) . | \
	$(GREP) -e "\\.json$$" | \
	$(GREP) -Fvxf <($(SF_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_JSONLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	check-jsonlint \

# ------------------------------------------------------------------------------

.PHONY: check-jsonlint
check-jsonlint:
	[[ "$(words $(SF_JSONLINT_FILES))" = "0" ]] || { \
		$(JSONLINT) $(SF_JSONLINT_FILES); \
	}
