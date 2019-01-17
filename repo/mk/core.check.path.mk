SF_PATH_LINT_RE := ^[a-z0-9/.-]\+$$

SF_PATH_FILES_IGNORE := \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \
	-e "^.github/" \
	-e "^AUTHORS$$" \
	-e "^Brewfile.inc.sh$$" \
	-e "^README" \
	-e "/README" \
	-e "^Makefile" \
	-e "/Makefile" \
	-e "/Pipfile" \

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
			$(ECHO_ERR) "$${f} not following file/folder naming convention."; \
			exit 1; \
		done; \
	}
