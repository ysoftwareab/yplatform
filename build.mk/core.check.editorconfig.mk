# Adds a 'check-editoconfig' internal target to run 'editorconfig-checker',
# over SF_ECCHECKER_FILES (defaults to all committed and staged files).
# The 'check-editorconfig' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# The editorconfig-checker executable is lazy-found inside $PATH.
# The arguments to the editorconfig-checker executable can be changed via ECCHECKER_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to SF_ECCHECKER_FILES_IGNORE:
# SF_ECCHECKER_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

SF_IS_TRANSCRYPTED ?= false

ECCHECKER = $(call which,ECCHECKER,editorconfig-checker) --ignore-defaults
$(foreach VAR,ECCHECKER,$(call make-lazy,$(VAR)))

ECCHECKER_ARGS += \

# backwards compat
SF_ECLINT_FILES_IGNORE += \
	-e "^$$" \

SF_ECCHECKER_FILES_IGNORE += \
	-e "^$$" \
	$(SF_ECLINT_FILES_IGNORE) \
	$(SF_VENDOR_FILES_IGNORE) \

SF_ECCHECKER_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(SF_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_ECCHECKER_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS += \
	check-editorconfig \

# ------------------------------------------------------------------------------

.PHONY: check-editorconfig
check-editorconfig:
	SF_ECCHECKER_FILES_TMP=($(SF_ECCHECKER_FILES)); \
	[[ "$${#SF_ECCHECKER_FILES_TMP[@]}" = "0" ]] || { \
		$(ECCHECKER) $(ECCHECKER_ARGS) $${SF_ECCHECKER_FILES_TMP[@]}; \
	}
