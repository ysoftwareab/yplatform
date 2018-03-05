GIT_EXCLUDES_FILE := $(shell $(GIT) config core.excludesfile)

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	build-npmignore

# ------------------------------------------------------------------------------

.PHONY: build-npmignore
build-npmignore:
	$(CAT) \
		<($(ECHO) "# ------------------------------------------------------------------------------") \
		<($(ECHO) "# $(GIT_EXCLUDES_FILE):") \
		$(GIT_EXCLUDES_FILE) \
		<($(ECHO) "") \
		<($(ECHO) "# ------------------------------------------------------------------------------") \
		<($(ECHO) "# .gitignore:") \
		.gitignore \
		<($(ECHO) "") \
		<($(ECHO) "# ------------------------------------------------------------------------------") \
		<($(ECHO) "# .gitignore.npm:") \
		.gitignore.npm \
		> .npmignore 2>/dev/null
