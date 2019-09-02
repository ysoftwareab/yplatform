# Adds a 'check-flake' target to run 'flake8'
# over SF_FLAKE_FILES (defaults to all committed and staged *.py files).
# The 'check-flake' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# The flake8 executable is found via pipenv.
# The arguments to the flake executable can be changed via FLAKE_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to SF_FLAKE_FILES_IGNORE:
# SF_FLAKE_FILES_IGNORE := \
#	$(SF_FLAKE_FILES_IGNORE) \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# ------------------------------------------------------------------------------

FLAKE = $(PIPENV) run flake8
FLAKE_ARGS ?=

SF_FLAKE_FILES_IGNORE := \
	-e "^$$"

SF_FLAKE_FILES = $(shell $(GIT_LS) . | \
	$(GREP) -v $(SF_FLAKE_FILES_IGNORE) | \
	$(GREP) -e "\.py$$" | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	check-flake \

# ------------------------------------------------------------------------------

.PHONY: check-flake
check-flake:
	$(FLAKE) $(FLAKE_ARGS) $(SF_FLAKE_FILES)
