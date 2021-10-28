# Adds an internal 'deps-git-reset-mtime' target that will
# reset file modification time to last-commit time.
#
# ------------------------------------------------------------------------------

YP_DEPS_TARGETS += \
	deps-git-reset-mtime \

# ------------------------------------------------------------------------------

.PHONY: deps-git-reset-mtime
deps-git-reset-mtime:
	if [[ "$$(git rev-parse --is-shallow-repository)" = "true" ]]; then \
		$(ECHO_INFO) "Shallow git repository detected."; \
		$(ECHO_SKIP) "Resetting mtime based on git log..."; \
	else \
		$(ECHO_DO) "Resetting mtime based on git log..."; \
		$(SUPPORT_FIRECLOUD_DIR)/bin/git-reset-mtime; \
		$(ECHO_DONE); \
	fi
