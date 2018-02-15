JEST = $(call which,JEST,jest)

.PHONY: test
test: check ## Test.
	@$(ECHO_DO) "Testing..."
	$(JEST)
	@$(ECHO_DONE)
