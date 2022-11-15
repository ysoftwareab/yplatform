# Adds a 'check-shellcheck' target to run 'shellcheck'
# over YP_SHELLCHECK_FILES (defaults to all committed and staged *.sh files,
# as well as executable files with a shebang that mentiones 'bash' or 'sh').
# The 'check-shellcheck' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The shellcheck executable is lazy-found inside $PATH.
# The arguments to the shellcheck executable can be changed via SHELLCHECK_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_SHELLCHECK_FILES_IGNORE:
# YP_SHELLCHECK_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

YP_IS_TRANSCRYPTED ?= false

SHELLCHECK = $(call npm-which,SHELLCHECK,shellcheck)
$(foreach VAR,SHELLCHECK,$(call make-lazy-once,$(VAR)))

SHELLCHECK_ARGS += \

YP_SHELLCHECK_FILES_IGNORE += \
	-e "^$$" \
	$(YP_VENDOR_FILES_IGNORE) \

YP_SHELLCHECK_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\.sh$$" | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(YP_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(YP_SHELLCHECK_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g") \
	$(shell $(GIT_LS) . | while read -r FILE; do \
		[[ ! -L "$${FILE}" ]] || continue; \
		[[ -f "$${FILE}" ]] || continue; \
		[[ -x "$${FILE}" ]] || continue; \
		$(HEAD) -n1 "$${FILE}" | $(GREP) "^#!/" | $(GREP) -q -e "\b\(bash\|sh\)\b" || continue; \
		$(ECHO) "$${FILE}"; \
	done | \
	$(GREP) -v $(YP_SHELLCHECK_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

YP_CHECK_TARGETS += \
	check-shellcheck \

# ------------------------------------------------------------------------------

.PHONY: check-shellcheck
check-shellcheck:
	YP_SHELLCHECK_FILES_TMP=($(YP_SHELLCHECK_FILES)); \
	[[ "$${#YP_SHELLCHECK_FILES_TMP[@]}" = "0" ]] || { \
		$(SHELLCHECK) $(SHELLCHECK_ARGS) $${YP_SHELLCHECK_FILES_TMP[@]}; \
	}
