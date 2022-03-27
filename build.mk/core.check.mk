# Adds a 'check' target that will call all the targets in YP_CHECK_TARGETS.
#
# To add another check target do
# YP_CHECK_TARGETS += \
#	check-something-else \
#
# ------------------------------------------------------------------------------

YP_CHECK_TARGETS += \

# ------------------------------------------------------------------------------

.PHONY: check
check: ## Check.
	[[ "$(words $(YP_CHECK_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Checking..."; \
		$(MAKE) --no-print-directory $(YP_CHECK_TARGETS); \
		$(ECHO_DONE); \
	}
