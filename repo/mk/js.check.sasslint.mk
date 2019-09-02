# Adds a 'check-sasslint' target to run 'sasslint'
# over SF_SASSLINT_FILES (defaults to all committed and staged *.sass and *.scss files).
# The 'check-sasslint' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# The sasslint executable is lazy-found inside ./node_modules/.bin and $PATH.
# The arguments to the sasslint executable can be changed via SASSLINT_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to SF_SASSLINT_FILES_IGNORE:
# SF_SASSLINT_FILES_IGNORE := \
#	$(SF_SASSLINT_FILES_IGNORE) \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

SF_IS_TRANSCRYPTED ?= false

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
	$(GREP) -e "\\.\\(sass\\|scss\\)$$" | \
	$(GREP) -Fvxf <($(SF_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_SASSLINT_FILES_IGNORE) | \
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
