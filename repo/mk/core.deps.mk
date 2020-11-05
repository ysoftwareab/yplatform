# Adds a 'deps' target that will call all the targets in SF_DEPS_TARGETS.
#
# To add another deps target do
# SF_DEPS_TARGETS += \
#	deps-for-something-else \
#
# ------------------------------------------------------------------------------
#
# Adds an internal 'deps-git' target will
# - install git submodules
# - reset file modification time to last-commit time
#
# ------------------------------------------------------------------------------

SF_DEPS_TARGETS += \
	deps-git \

# ------------------------------------------------------------------------------

.PHONY: deps-git
deps-git:
	$(GIT) submodule sync --recursive
	$(GIT) submodule update --init --recursive
ifneq (,$(CI))
	$(GIT) rev-parse --is-shallow-repository || $(SUPPORT_FIRECLOUD_DIR)/bin/git-reset-mtime
endif


.PHONY: deps
deps: ## Fetch dependencies.
	[[ "$(words $(SF_DEPS_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Fetching dependencies..."; \
		$(MAKE) $(SF_DEPS_TARGETS); \
		$(ECHO_DONE); \
	}
