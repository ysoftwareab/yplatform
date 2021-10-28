# Adds a 'check-jsonlint' internal target to run 'jsonlint'
# over YP_JSONLINT_FILES (defaults to all committed and staged *.json files).
# The 'check-jsonlint' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The jsonlint executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the jsonlint executable can be changed via JSONLINT_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_JSONLINT_FILES_IGNORE:
# YP_JSONLINT_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

YP_IS_TRANSCRYPTED ?= false

JSONLINT = $(YP_DIR)/bin/jsonlint

JSONLINT_ARGS += \

YP_JSONLINT_FILES_IGNORE += \
	-e "^$$" \
	$(YP_VENDOR_FILES_IGNORE) \

YP_JSONLINT_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\.json$$" | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(YP_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(YP_JSONLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

YP_CHECK_TARGETS += \
	check-jsonlint \

# ------------------------------------------------------------------------------

.PHONY: check-jsonlint
check-jsonlint:
	YP_JSONLINT_FILES_TMP=($(YP_JSONLINT_FILES)); \
	[[ "$${#YP_JSONLINT_FILES_TMP[@]}" = "0" ]] || { \
		$(JSONLINT) $(JSONLINT_ARGS) $${YP_JSONLINT_FILES_TMP[@]}; \
	}
