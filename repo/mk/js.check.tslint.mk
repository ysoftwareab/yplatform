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
	[[ "$(words $(TS_FILES))" = "0" ]] || { \
		$(TSLINT) $(TSLINT_ARGS) $(TS_FILES) || { \
			$(TSLINT) $(TSLINT_ARGS) --fix $(TS_FILES) 2>/dev/null >&2; \
			exit 1; \
		}; \
	}
