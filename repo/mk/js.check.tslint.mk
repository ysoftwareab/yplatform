TSFMT = $(call which,TSFMT,tsfmt)
TSLINT = $(call which,TSLINT,tslint)
$(foreach VAR,TSFMT TSLINT,$(call make-lazy,$(VAR)))

TSLINT_ARGS ?=
TSLINT_ARGS := \
	$(TSLINT_ARGS) \


SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	lint-tslint \

# ------------------------------------------------------------------------------

.PHONY: lint-tslint
lint-tslint:
	[[ "$(words $(TS_FILES))" = "0" ]] || { \
		$(TSLINT) $(TSLINT_ARGS) $(TS_FILES) || { \
			$(TSLINT) $(TSLINT_ARGS) --fix $(TS_FILES) 2>/dev/null >&2; \
			exit 1; \
		}; \
		$(TSFMT) --verify -- $(TS_FILES) || { \
			$(TSFMT) --replace -- $(TS_FILES) 2>/dev/null >&2; \
			exit 1; \
		}; \
	}
