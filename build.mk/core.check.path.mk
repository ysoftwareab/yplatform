# Adds a 'check-path' internal target to run path and filename checks
# over YP_PATH_FILES (defaults to all committed and staged files).
# The 'check-path' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The check is a match check against a regular expression defined via YP_PATH_LINT_RE.
# The default YP_PATH_LINT_RE allow alphanumerics, forward slash, dot and hyphen.
# Why not underscore?
# - https://www.rothschillermd.com/file-naming-conventions/
# - underscore is not a word separators, hyphen is
# - ISO 8601 (dates) removed underscore in favour of hyphen
# - there's life beyond python :) Seriously, when in need, simply modify to allow underscore
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_PATH_FILES_IGNORE:
# YP_PATH_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# ------------------------------------------------------------------------------

YP_PATH_LINT_RE := ^[a-z0-9/.-]\+$$

YP_PATH_FILES_IGNORE += \
	-e "^$$" \
	$(YP_VENDOR_FILES_IGNORE) \

YP_PATH_FILES_IGNORE += \
	-e "^.github/" \

YP_PATH_FILES_IGNORE += \
	-e "^AUTHORS$$" \

YP_PATH_FILES_IGNORE += \
	-e "^Brewfile" \
	-e "/Brewfile" \

YP_PATH_FILES_IGNORE += \
	-e "^CONST\.inc$$" \
	-e "^CONST\.inc\.secret$$" \

YP_PATH_FILES_IGNORE += \
	-e "^Dockerfile" \
	-e "/Dockerfile" \

YP_PATH_FILES_IGNORE += \
	-e "^Makefile" \
	-e "/Makefile" \

YP_PATH_FILES_IGNORE += \
	-e "^README" \
	-e "/README" \

YP_PATH_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(YP_PATH_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

YP_CHECK_TARGETS += \
	check-path \

# ------------------------------------------------------------------------------

.PHONY: check-path
check-path:
	YP_PATH_FILES_TMP=($(YP_PATH_FILES)); \
	[[ "$${#YP_PATH_FILES_TMP[@]}" = "0" ]] || { \
		for f in $${YP_PATH_FILES_TMP[@]}; do \
			$(ECHO) "$${f}" | $(GREP) -qv "$(YP_PATH_LINT_RE)" || continue; \
			$(ECHO_ERR) "$${f} not following file/folder naming convention '$(YP_PATH_LINT_RE)'."; \
			exit 1; \
		done; \
	}
