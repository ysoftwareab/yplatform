# Adds a 'check-eclint' internal target to run 'editorconfig-checker', or fallback to deprecated 'eclint',
# over SF_ECLINT_FILES (defaults to all committed and staged files).
# The 'check-eclint' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# The editorconfig-checker executable is lazy-found inside $PATH.
# The arguments to the editorconfig-checker executable can be changed via ECCHECKER_ARGS.
#
# The eclint executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the eclint executable can be changed via ECLINT_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to SF_ECLINT_FILES_IGNORE:
# SF_ECLINT_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

SF_IS_TRANSCRYPTED ?= false

ECCHECKER = $(call which,ECCHECKER,editorconfig-checker) --ignore-defaults
ECLINT = $(call npm-which,ECLINT,eclint)
$(foreach VAR,ECCHECKER ECLINT,$(call make-lazy,$(VAR)))

ECCHECKER_ARGS += \

ECLINT_ARGS += \

SF_ECLINT_FILES_IGNORE += \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \

SF_ECLINT_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(SF_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_ECLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS += \
	check-eclint \

# ------------------------------------------------------------------------------

.PHONY: check-eclint
check-eclint:
	SF_ECLINT_FILES_TMP=($(SF_ECLINT_FILES)); \
	[[ "$${#SF_ECLINT_FILES_TMP[@]}" = "0" ]] || { \
		if [[ "$(ECCHECKER)" = "ECCHECKER_NOT_FOUND" ]]; then \
			$(ECLINT) check $(ECLINT_ARGS) $${SF_ECLINT_FILES_TMP[@]} || { \
				$(ECLINT) fix $(ECLINT_ARGS) $${SF_ECLINT_FILES_TMP[@]} 2>/dev/null >&2; \
				exit 1; \
			}; \
		else \
			$(ECCHECKER) $(ECCHECKER_ARGS) $${SF_ECLINT_FILES_TMP[@]}; \
		fi; \
	}
