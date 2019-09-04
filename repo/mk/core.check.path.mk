# Adds a 'check-path' internal target to run path and filename checks
# over SF_PATH_FILES (defaults to all committed and staged files).
# The 'check-path' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# The check is a match check against a regular expression defined via SF_PATH_LINT_RE.
#
# For convenience, specific files can be ignored
# via grep arguments given to SF_PATH_FILES_IGNORE:
# SF_PATH_FILES_IGNORE := \
#	$(SF_PATH_FILES_IGNORE) \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# ------------------------------------------------------------------------------

SF_PATH_LINT_RE := ^[a-z0-9/.-]\+$$

SF_PATH_FILES_IGNORE := \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \
	-e "^.github/" \
	-e "^Brewfile.inc.sh$$" \

SF_PATH_FILES_IGNORE := \
	$(SF_PATH_FILES_IGNORE) \
	-e "^AUTHORS$$" \

SF_PATH_FILES_IGNORE := \
	$(SF_PATH_FILES_IGNORE) \
	-e "^CONST\.inc$$" \
	-e "^CONST\.inc\.secret$$" \

SF_PATH_FILES_IGNORE := \
	$(SF_PATH_FILES_IGNORE) \
	-e "^Makefile" \
	-e "/Makefile" \

SF_PATH_FILES_IGNORE := \
	$(SF_PATH_FILES_IGNORE) \
	-e "^README" \
	-e "/README" \

SF_PATH_FILES = $(shell $(GIT_LS) . | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_PATH_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	check-path \

# ------------------------------------------------------------------------------

.PHONY: check-path
check-path:
	[[ "$(words $(SF_PATH_FILES))" = "0" ]] || { \
		for f in $(SF_PATH_FILES); do \
			$(ECHO) "$${f}" | $(GREP) -qv "$(SF_PATH_LINT_RE)" || continue; \
			$(ECHO_ERR) "$${f} not following file/folder naming convention '$(SF_PATH_LINT_RE)'."; \
			exit 1; \
		done; \
	}
