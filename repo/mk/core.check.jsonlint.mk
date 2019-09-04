# Adds a 'check-jsonlint' internal target to run 'jsonlint'
# over SF_JSONLINT_FILES (defaults to all committed and staged *.json files).
# The 'check-jsonlint' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# The jsonlint executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the jsonlint executable can be changed via JSONLINT_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to SF_JSONLINT_FILES_IGNORE:
# SF_JSONLINT_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

SF_IS_TRANSCRYPTED ?= false

JSONLINT = $(SUPPORT_FIRECLOUD_DIR)/bin/jsonlint

JSONLINT_ARGS += \

SF_JSONLINT_FILES_IGNORE += \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \

SF_JSONLINT_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\\.json$$" | \
	$(GREP) -Fvxf <($(SF_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_JSONLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS += \
	check-jsonlint \

# ------------------------------------------------------------------------------

.PHONY: check-jsonlint
check-jsonlint:
	[[ "$(words $(SF_JSONLINT_FILES))" = "0" ]] || { \
		$(JSONLINT) $(JSONLINT_ARGS) $(SF_JSONLINT_FILES); \
	}
