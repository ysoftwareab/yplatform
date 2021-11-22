# Adds a 'check-path-sensitive' internal target to run case-sensitive checks
# over YP_PATH_SENSITIVE_FILES (defaults to all committed and staged files).
# The 'check-path-sensitive' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The check will fail if two files would collide on a case-insensitive file system.
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_PATH_SENSITIVE_FILES_IGNORE:
# YP_PATH_SENSITIVE_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# ------------------------------------------------------------------------------

YP_PATH_SENSITIVE_FILES_IGNORE += \
	-e "^$$" \
	$(YP_VENDOR_FILES_IGNORE) \

YP_PATH_SENSITIVE_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(YP_PATH_SENSITIVE_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

YP_CHECK_TARGETS += \
	check-path-sensitive \

# ------------------------------------------------------------------------------

.PHONY: check-path-sensitive
check-path-sensitive:
	YP_PATH_SENSITIVE_FILES_TMP=($(YP_PATH_SENSITIVE_FILES)); \
	[[ "$${#YP_PATH_SENSITIVE_FILES_TMP[@]}" = "0" ]] || { \
		YP_PATH_SENSITIVE_FILES_TMP2=(); \
		for f in $${YP_PATH_SENSITIVE_FILES_TMP[@]}; do \
			f_lowercase="$$(echo "$$f" | tr "[:upper:]" "[:lower:]")"; \
			YP_PATH_SENSITIVE_FILES_TMP2+=("$$f_lowercase|$$f"); \
		done; \
		YP_PATH_SENSITIVE_FILES_TMP2="$$(IFS=$$'\n'; $(ECHO) "$${YP_PATH_SENSITIVE_FILES_TMP2[*]}")"; \
		YP_PATH_NON_UNIQUE="$$(echo "$${YP_PATH_SENSITIVE_FILES_TMP2}" | $(CUT) -d"|" -f1 | $(SORT) | $(UNIQ) -d)"; \
		[[ -z "$${YP_PATH_NON_UNIQUE}" ]] || $(ECHO_ERR) "Some files will collide on case-insensitive file systems:"; \
		$(ECHO) "$${YP_PATH_NON_UNIQUE}" | while read -r NON_UNIQUE; do \
			[[ -n "$${NON_UNIQUE}" ]] || continue; \
			echo "$${YP_PATH_SENSITIVE_FILES_TMP2}" | $(GREP) "^$${NON_UNIQUE}|" | $(CUT) -d"|" -f2; \
		done; \
		[[ -z "$${YP_PATH_NON_UNIQUE}" ]] || exit 1; \
	}
