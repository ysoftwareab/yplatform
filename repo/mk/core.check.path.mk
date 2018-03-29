PATH_FILES_IGNORE := \
	-e "^$$" \
	$(VENDOR_FILES_IGNORE) \
	-e "^AUTHORS$$" \
	-e "^README" \
	-e "/README" \
	-e "^Makefile" \
	-e "/Makefile" \

PATH_FILES = $(shell $(GIT_LS) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(PATH_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	lint-path \

SF_PATH_LINT_RE := ^[a-z0-9/.-]\+$$

# ------------------------------------------------------------------------------

.PHONY: lint-path
lint-path:
	[[ "$(words $(PATH_FILES))" = "0" ]] || { \
		for f in $(PATH_FILES); do \
			$(ECHO) "$${f}" | $(GREP) -qv "$(SF_PATH_LINT_RE)" || continue; \
			$(ECHO_ERR) "$${f} not following file/folder naming convention."; \
			exit 1; \
		done; \
	}
