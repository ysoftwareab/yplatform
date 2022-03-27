# Adds a 'deps' target that will call all the targets in YP_DEPS_TARGETS.
#
# To add another deps target do
# YP_DEPS_TARGETS += \
#	deps-for-something-else \
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

.PHONY: deps
deps: ## Fetch dependencies.
	[[ "$(words $(YP_DEPS_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Fetching dependencies..."; \
		$(MAKE) --no-print-directory $(YP_DEPS_TARGETS); \
		$(ECHO_DONE); \
	}
