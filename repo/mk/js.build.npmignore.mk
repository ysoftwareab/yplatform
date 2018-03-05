GIT_EXCLUDES_FILE := $(shell $(GIT) config core.excludesfile)

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	build-npmignore

# ------------------------------------------------------------------------------

.PHONY: build-npmignore
build-npmignore:
	$(CAT) $(GIT_EXCLUDES_FILE) .gitignore .gitignore.npm > .npmignore 2>/dev/null
