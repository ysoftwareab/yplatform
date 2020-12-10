# Adds a 'deps' target that will call all the targets in SF_DEPS_TARGETS.
#
# To add another deps target do
# SF_DEPS_TARGETS += \
#	deps-for-something-else \
#
# ------------------------------------------------------------------------------
#
# Adds an internal 'deps-git-submodules' target that will sync git submodules.
#
# Adds an internal 'deps-git-reset-mtime' target that will
# reset file modification time to last-commit time.
#
# ------------------------------------------------------------------------------

SF_DEPS_TARGETS += \
	deps-git-submodules \
	deps-git-reset-mtime \

# ------------------------------------------------------------------------------

.PHONY: deps-git-submodules
deps-git-submodules:
	$(ECHO_DO) "Syncing git submodules..."
	$(GIT) submodule sync --recursive
	$(GIT) submodule update --init --recursive
	$(ECHO_DONE)


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


.PHONY: deps
deps: ## Fetch dependencies.
	[[ "$(words $(SF_DEPS_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Fetching dependencies..."; \
		$(MAKE) $(SF_DEPS_TARGETS); \
		$(ECHO_DONE); \
	}
