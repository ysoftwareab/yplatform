IS_TRANSCRYPTED = $(shell $(GIT) config --local transcrypted.version >/dev/null && echo true || echo false)

# ------------------------------------------------------------------------------

VENDOR_FILES_IGNORE := \
	$(VENDOR_FILES_IGNORE) \
	-e "^.transcrypt/" \
	-e "^transcrypt$$" \
