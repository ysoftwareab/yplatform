# Adds a 'build' target that will call all the targets in SF_BUILD_TARGETS.
#
# To add another build target do
# SF_BUILD_TARGETS := \
#	$(SF_BUILD_TARGETS) \
#	build-something-else \
#
# ------------------------------------------------------------------------------

SF_BUILD_TARGETS := \

# ------------------------------------------------------------------------------

.PHONY: build
build: ## Build.
	[[ "$(words $(SF_BUILD_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Building..."; \
		$(MAKE) $(SF_BUILD_TARGETS); \
		$(ECHO_DONE); \
	}
