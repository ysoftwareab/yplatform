# Adds a 'build' target that will call all the targets in YP_BUILD_TARGETS.
#
# To add another build target do
# YP_BUILD_TARGETS += \
#	build-something-else \
#
# ------------------------------------------------------------------------------
#
# Adds a 'dist' target as an extensible alias to 'build', closely following GNU conventions.
#
# To add another dist target do
# YP_DIST_TARGETS += \
#	dist-something-else \
#
# ------------------------------------------------------------------------------

YP_BUILD_TARGETS += \

YP_DIST_TARGETS += \
	build \

# ------------------------------------------------------------------------------

.PHONY: build
build: ## Build.
	[[ "$(words $(YP_BUILD_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Building..."; \
		$(MAKE) --no-print-directory $(YP_BUILD_TARGETS); \
		$(ECHO_DONE); \
	}


.PHONY: dist
dist:
	[[ "$(words $(YP_DIST_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Packaging a distribution..."; \
		$(MAKE) --no-print-directory $(YP_DIST_TARGETS); \
		$(ECHO_DONE); \
	}
