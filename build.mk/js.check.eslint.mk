# Adds a 'check-eslint' target to run 'eslint'
# over YP_ESLINT_FILES (defaults to all committed and staged *.js and *.ts files,
# as well as executable files with a shebang that mentiones 'node').
# The 'check-eslint' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The eslint executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the eslint executable can be changed via ESLINT_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_ESLINT_FILES_IGNORE:
# YP_ESLINT_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

YP_IS_TRANSCRYPTED ?= false

ESLINT = $(call npm-which,ESLINT,eslint)
$(foreach VAR,ESLINT,$(call make-lazy-once,$(VAR)))

ESLINT_ARGS += \
	--ignore-pattern '!*' \

YP_ESLINT_FILES_IGNORE += \
	-e "^$$" \
	$(YP_VENDOR_FILES_IGNORE) \

YP_ESLINT_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\.\(js\|ts\)$$" | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(YP_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(YP_ESLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g") \
	$(shell $(GIT_LS) . | while read -r FILE; do \
		[[ ! -L "$${FILE}" ]] || continue; \
		[[ -f "$${FILE}" ]] || continue; \
		[[ -x "$${FILE}" ]] || continue; \
		$(HEAD) -n1 "$${FILE}" | $(GREP) "^#!/" | $(GREP) -q -e "\bnode\b" || continue; \
		$(ECHO) "$${FILE}"; \
	done | \
	$(GREP) -v $(YP_ESLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

YP_CHECK_TARGETS += \
	check-eslint \

# ------------------------------------------------------------------------------

.PHONY: check-eslint
check-eslint:
	YP_ESLINT_FILES_TMP=($(YP_ESLINT_FILES)); \
	[[ "$${#YP_ESLINT_FILES_TMP[@]}" = "0" ]] || { \
		$(ESLINT) $(ESLINT_ARGS) $${YP_ESLINT_FILES_TMP[@]} || { \
			$(ESLINT) $(ESLINT_ARGS) --fix $${YP_ESLINT_FILES_TMP[@]} 2>/dev/null >&2; \
			exit 1; \
		}; \
	}
