SF_TEST_TARGETS := \

# ------------------------------------------------------------------------------

.PHONY: test
test: ## Test.
	[[ "$(words $(SF_TEST_TARGETS))" = "0" ]] || { \
		$(ECHO_DO) "Testing..."; \
		$(MAKE) $(SF_TEST_TARGETS); \
		$(ECHO_DONE); \
	}
