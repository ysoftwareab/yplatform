# Adds a 'deps' target that will call all the targets in YP_DEPS_TARGETS.
#
# To add another deps target do
# YP_DEPS_TARGETS += \
#	deps-for-something-else \
#
# ------------------------------------------------------------------------------
#
# Adds a 'deps/upgrade' target that will call all the targets in YP_DEPS_UPGRADE_TARGETS.
#
# To add another deps/upgrade target do
# YP_DEPS_UPGRADE_TARGETS += \
#	deps-upgrade-for-something-else \
#
# ------------------------------------------------------------------------------

YP_DEPS_TARGETS += \

YP_DEPS_UPGRADE_TARGETS += \

# ------------------------------------------------------------------------------

.PHONY: deps
deps: ## Fetch dependencies.
	[[ "$(words $(YP_DEPS_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Fetching dependencies..."; \
		$(MAKE) --no-print-directory $(YP_DEPS_TARGETS); \
		$(ECHO_DONE); \
	}

.PHONY: deps/upgrade
deps/upgrade: ## Upgrade dependencies.
	[[ "$(words $(YP_DEPS_UPGRADE_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Upgrade dependencies..."; \
		$(MAKE) --no-print-directory $(YP_DEPS_UPGRADE_TARGETS); \
		$(ECHO_DONE); \
	}
