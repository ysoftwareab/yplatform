# Adds a 'build' target that will call all the targets in SF_BUILD_TARGETS.
#
# To add another build target do
# SF_BUILD_TARGETS += \
#	build-something-else \
#
# ------------------------------------------------------------------------------
#
# Adds a 'dist' target as an extensible alias to 'build', closely following GNU conventions.
#
# To add another dist target do
# SF_DIST_TARGETS += \
#	dist-something-else \
#
# ------------------------------------------------------------------------------

SF_BUILD_TARGETS += \

SF_DIST_TARGETS += \
	build \

# ------------------------------------------------------------------------------

.PHONY: build
build: ## Build.
	[[ "$(words $(SF_BUILD_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Building..."; \
		$(MAKE) $(SF_BUILD_TARGETS); \
		$(ECHO_DONE); \
	}


.PHONY: dist
dist:
	[[ "$(words $(SF_DIST_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Packaging a distribution..."; \
		$(MAKE) $(SF_DIST_TARGETS); \
		$(ECHO_DONE); \
	}
