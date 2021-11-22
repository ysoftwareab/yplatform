# Adds a 'check-symlinks' internal target to run broken-symlinks checks
# over YP_SYMLINK_FILES (defaults to all committed and staged files).
# The 'check-symlinks' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The check will fail if a symlink cannot be dereferenced.
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_SYMLINK_FILES_IGNORE:
# YP_SYMLINK_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# ------------------------------------------------------------------------------

YP_SYMLINK_FILES_IGNORE += \
	-e "^$$" \
	$(YP_VENDOR_FILES_IGNORE) \

YP_SYMLINK_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(YP_SYMLINK_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

YP_CHECK_TARGETS += \
	check-symlinks \

# ------------------------------------------------------------------------------

.PHONY: check-symlinks
check-symlinks:
	YP_SYMLINK_FILES_TMP=($(YP_SYMLINK_FILES)); \
	[[ "$${#YP_SYMLINK_FILES_TMP[@]}" = "0" ]] || { \
		for f in $${YP_SYMLINK_FILES_TMP[@]}; do \
			[[ -L "$$f" ]] || continue; \
			[[ -e "$$f" ]] || { \
				$(ECHO_ERR) "$$f is a broken symlink."; \
				exit 1; \
			} \
		done; \
	}
