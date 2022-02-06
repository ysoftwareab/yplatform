# Adds a 'check-sasslint' internal target to run 'sasslint'
# over YP_SASSLINT_FILES (defaults to all committed and staged *.sass and *.scss files).
# The 'check-sasslint' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The sasslint executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the sasslint executable can be changed via SASSLINT_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_SASSLINT_FILES_IGNORE:
# YP_SASSLINT_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

YP_IS_TRANSCRYPTED ?= false

SASSLINT = $(call npm-which,SASSLINT,sass-lint)
$(foreach VAR,SASSLINT,$(call make-lazy-once,$(VAR)))

SASSLINT_ARGS += \
	--no-exit \
	--verbose \

YP_SASSLINT_FILES_IGNORE += \
	-e "^$$" \
	$(YP_VENDOR_FILES_IGNORE) \

YP_SASSLINT_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\.\(sass\|scss\)$$" | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(YP_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(YP_SASSLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g") \

YP_CHECK_TARGETS += \
	check-sasslint \

# ------------------------------------------------------------------------------

.PHONY: check-sasslint
check-sasslint:
	YP_SASSLINT_FILES_TMP=($(YP_SASSLINT_FILES)); \
	[[ "$${#YP_SASSLINT_FILES_TMP[@]}" = "0" ]] || { \
		$(SASSLINT) $(SASSLINT_ARGS) $${YP_SASSLINT_FILES_TMP[@]}; \
	}
