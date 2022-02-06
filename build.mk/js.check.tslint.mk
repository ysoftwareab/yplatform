# Adds a 'check-tslint' internal target to run 'tslint'.
# The 'check-tslint' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The tslint executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the tslint executable can be changed via TSLINT_ARGS.
#
# ------------------------------------------------------------------------------


TSLINT = $(call npm-which,TSLINT,tslint)
$(foreach VAR,TSLINT,$(call make-lazy-once,$(VAR)))

TSLINT_ARGS += \
	--format verbose \

YP_CHECK_TARGETS += \
	check-tslint \

# ------------------------------------------------------------------------------

.PHONY: check-tslint
check-tslint:
	YP_TSLINT_FILES_TMP=($(YP_TSLINT_FILES)); \
	[[ "$${#YP_TSLINT_FILES_TMP[@]}" = "0" ]] || { \
		$(TSLINT) $(TSLINT_ARGS) $${YP_TSLINT_FILES_TMP[@]} || { \
			$(TSLINT) $(TSLINT_ARGS) --fix $${YP_TSLINT_FILES_TMP[@]} 2>/dev/null >&2; \
			exit 1; \
		}; \
	}
