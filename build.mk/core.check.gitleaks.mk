# Adds a 'check-gitleaks' internal target to run 'gitleaks',
# over YP_GITLEAKS_FILES (defaults to all committed and staged files).
# The 'check-gitleaks' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The gitleaks executable is lazy-found inside $PATH.
# The arguments to the gitleaks executable can be changed via GITLEAKS_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_GITLEAKS_FILES_IGNORE:
# YP_GITLEAKS_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

YP_IS_TRANSCRYPTED ?= false

# GITLEAKS = $(call which,GITLEAKS,gitleaks)
# $(foreach VAR,GITLEAKS,$(call make-lazy-once,$(VAR)))

# using our hardcoded gitleaks because gitleaks seems too volatile for now, and we want to lock its version
GITLEAKS = $(YP_DIR)/bin/gitleaks

GITLEAKS_ARGS += \
	detect \
	--redact \
	--log-opts "--full-history HEAD"

YP_GITLEAKS_FILES_IGNORE += \
	-e "^$$" \
	$(YP_VENDOR_FILES_IGNORE) \

YP_GITLEAKS_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(YP_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(YP_GITLEAKS_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

YP_CHECK_TARGETS += \
	check-gitleaks \

# ------------------------------------------------------------------------------

.PHONY: check-gitleaks
check-gitleaks:
	YP_GITLEAKS_FILES_TMP=($(YP_GITLEAKS_FILES)); \
	[[ "$${#YP_GITLEAKS_FILES_TMP[@]}" = "0" ]] || { \
		$(GITLEAKS) $(GITLEAKS_ARGS) $${YP_GITLEAKS_FILES_TMP[@]}; \
	}
