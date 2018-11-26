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
	lint-flake \

# ------------------------------------------------------------------------------

.PHONY: lint-flake
lint-flake:
	$(FLAKE) $(FLAKE_ARGS) $(SF_FLAKE_FILES)
