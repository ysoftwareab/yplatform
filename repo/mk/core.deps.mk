# Adds a 'deps' target that will call all the targets in SF_DEPS_TARGETS.
#
# ------------------------------------------------------------------------------
#
# Adds an internal 'deps-git' target will install git submodules.
#
# ------------------------------------------------------------------------------

SF_DEPS_TARGETS := \
	deps-git \

# ------------------------------------------------------------------------------

.PHONY: deps-git
deps-git:
	$(GIT) submodule sync
	$(GIT) submodule update --init --recursive


.PHONY: deps
deps: ## Fetch dependencies.
	[[ "$(words $(SF_DEPS_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Fetching dependencies..."; \
		$(MAKE) $(SF_DEPS_TARGETS); \
		$(ECHO_DONE); \
	}
