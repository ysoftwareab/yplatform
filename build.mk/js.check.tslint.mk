# Adds a 'check-tslint' internal target to run 'tslint'.
# The 'check-tslint' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# The tslint executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the tslint executable can be changed via TSLINT_ARGS.
#
# ------------------------------------------------------------------------------


TSLINT = $(call npm-which,TSLINT,tslint)
$(foreach VAR,TSLINT,$(call make-lazy,$(VAR)))

TSLINT_ARGS += \
	--format verbose \

SF_CHECK_TARGETS += \
	check-tslint \

# ------------------------------------------------------------------------------

.PHONY: check-tslint
check-tslint:
	SF_TSLINT_FILES_TMP=($(SF_TSLINT_FILES)); \
	[[ "$${#SF_TSLINT_FILES_TMP[@]}" = "0" ]] || { \
		$(TSLINT) $(TSLINT_ARGS) $${SF_TSLINT_FILES_TMP[@]} || { \
			$(TSLINT) $(TSLINT_ARGS) --fix $${SF_TSLINT_FILES_TMP[@]} 2>/dev/null >&2; \
			exit 1; \
		}; \
	}
