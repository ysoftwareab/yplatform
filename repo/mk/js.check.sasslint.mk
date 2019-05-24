SASSLINT = $(call npm-which,SASSLINT,sass-lint)
$(foreach VAR,SASSLINT,$(call make-lazy,$(VAR)))

SASSLINT_ARGS ?=
SASSLINT_ARGS := \
	$(SASSLINT_ARGS) \
	--no-exit \
	--verbose

SF_SASSLINT_FILES_IGNORE := \
	-e "^$$"

SF_SASSLINT_FILES = $(shell $(GIT_LS) . | \
	$(GREP) -v $(SF_SASSLINT_FILES_IGNORE) | \
	$(GREP) -e "\\.\\(sass\\|scss\\)$$" | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g") \


SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	check-sasslint \

# ------------------------------------------------------------------------------

.PHONY: check-sasslint
check-sasslint:
	[[ "$(words $(SF_SASSLINT_FILES))" = "0" ]] || { \
		$(SASSLINT) $(SASSLINT_ARGS) $(SF_SASSLINT_FILES); \
	}
