# Adds a 'test' target that will call all the targets in YP_TEST_TARGETS.
#
# To add another test target do
# YP_TEST_TARGETS += \
#	test-something-else \
#
# ------------------------------------------------------------------------------

YP_TEST_TARGETS += \

# ------------------------------------------------------------------------------

.PHONY: test
test: ## Test.
	[[ "$(words $(YP_TEST_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Testing..."; \
		$(MAKE) --no-print-directory $(YP_TEST_TARGETS); \
		$(ECHO_DONE); \
	}
