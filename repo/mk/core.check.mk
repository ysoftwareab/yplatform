# Adds a 'check' target that will call all the targets in SF_CHECK_TARGETS.
#
# To add another check target do
# SF_CHECK_TARGETS := \
#	$(SF_CHECK_TARGETS) \
#	check-something-else \
#
# ------------------------------------------------------------------------------

SF_CHECK_TARGETS := \

# ------------------------------------------------------------------------------

.PHONY: check
check: ## Check.
	[[ "$(words $(SF_CHECK_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Checking..."; \
		$(MAKE) $(SF_CHECK_TARGETS); \
		$(ECHO_DONE); \
	}
