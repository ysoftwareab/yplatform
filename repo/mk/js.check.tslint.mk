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
