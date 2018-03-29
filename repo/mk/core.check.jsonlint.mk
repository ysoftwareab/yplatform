JSON_FILES_IGNORE := \
	-e "^$$" \
	$(VENDOR_FILES_IGNORE) \

JSON_FILES = $(shell $(GIT_LS) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -e ".json$$" | \
	$(GREP) -v $(JSON_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	lint-json \

JSONLINT = $(SUPPORT_FIRECLOUD_DIR)/bin/jsonlint

# ------------------------------------------------------------------------------

.PHONY: lint-json
lint-json:
	[[ "$(words $(JSON_FILES))" = "0" ]] || { \
		$(JSONLINT) $(JSON_FILES); \
	}
