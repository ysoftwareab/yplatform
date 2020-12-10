# Adds a 'test' target that will call all the targets in SF_TEST_TARGETS.
#
# To add another test target do
# SF_TEST_TARGETS += \
#	test-something-else \
#
# ------------------------------------------------------------------------------

SF_TEST_TARGETS += \

# ------------------------------------------------------------------------------

.PHONY: test
test: ## Test.
	[[ "$(words $(SF_TEST_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Testing..."; \
		$(MAKE) $(SF_TEST_TARGETS); \
		$(ECHO_DONE); \
	}
