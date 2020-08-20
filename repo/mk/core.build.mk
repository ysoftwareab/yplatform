# Adds a 'build' target that will call all the targets in SF_BUILD_TARGETS.
#
# To add another build target do
# SF_BUILD_TARGETS += \
#	build-something-else \
#
# ------------------------------------------------------------------------------
#
# Adds a 'dist' target as an alias to 'build', for closer following GNU conventions.
#
# ------------------------------------------------------------------------------

SF_BUILD_TARGETS += \

# ------------------------------------------------------------------------------

.PHONY: build
build: ## Build.
	[[ "$(words $(SF_BUILD_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Building..."; \
		$(MAKE) $(SF_BUILD_TARGETS); \
		$(ECHO_DONE); \
	}


.PHONY: dist
# NOTE don't list build as a dependency, in order to allow 'dist' to be fully overloaded
# dist: build
dist:
	$(MAKE) build
