SF_IS_TRANSCRYPTED = $(shell $(GIT) config --local transcrypted.version >/dev/null && echo true || echo false)

# ------------------------------------------------------------------------------

SF_VENDOR_FILES_IGNORE := \
	$(SF_VENDOR_FILES_IGNORE) \
	-e "^.transcrypt/" \
	-e "^transcrypt$$" \
