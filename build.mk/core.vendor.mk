# For convenience, vendor files can be ignored from various targets
# via grep arguments given to YP_VENDOR_FILES_IGNORE:
# YP_VENDOR_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# These files are meant to stay as close as possible to their original versions,
# rather than subject them to linters, etc.
#
# ------------------------------------------------------------------------------

YP_VENDOR_FILES_IGNORE += \
	-e "^$$" \
	-e "^LICENSE$$" \
	-e "^NOTICE$$" \
	-e "^UNLICENSE$$" \

# ------------------------------------------------------------------------------
