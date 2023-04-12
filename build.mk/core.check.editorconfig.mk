# Adds a 'check-editoconfig' internal target to run 'editorconfig-checker',
# over YP_ECCHECKER_FILES (defaults to all committed and staged files).
# The 'check-editorconfig' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The editorconfig-checker executable is lazy-found inside $PATH.
# The arguments to the editorconfig-checker executable can be changed via ECCHECKER_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_ECCHECKER_FILES_IGNORE:
# YP_ECCHECKER_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

YP_IS_TRANSCRYPTED ?= false

# ECCHECKER = $(call which,ECCHECKER,editorconfig-checker) --ignore-defaults
# $(foreach VAR,ECCHECKER,$(call make-lazy-once,$(VAR)))
ECCHECKER = $(YP_DIR)/bin/editorconfig-checker

ECCHECKER_ARGS += \

# backwards compat
YP_ECLINT_FILES_IGNORE += \
	-e "^$$" \

YP_ECCHECKER_FILES_IGNORE += \
	-e "^$$" \
	$(YP_ECLINT_FILES_IGNORE) \
	$(YP_VENDOR_FILES_IGNORE) \

YP_ECCHECKER_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(YP_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(YP_ECCHECKER_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

YP_CHECK_TARGETS += \
	check-editorconfig \

# ------------------------------------------------------------------------------

.PHONY: check-editorconfig
check-editorconfig:
	YP_ECCHECKER_FILES_TMP=($(YP_ECCHECKER_FILES)); \
	[[ "$${#YP_ECCHECKER_FILES_TMP[@]}" = "0" ]] || { \
#		NOTE filter out noise IBM424_ltr noise. See https://github.com/editorconfig-checker/editorconfig-checker/issues/252
		$(ECCHECKER) $(ECCHECKER_ARGS) $${YP_ECCHECKER_FILES_TMP[@]} | \
			{ $(GREP) -v -e "Could not decode the IBM424_ltr encoded file" -e "unrecognized charset IBM424_ltr" || true; }; \
	}
