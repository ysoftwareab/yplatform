JEST = $(call which,JEST,jest)
$(foreach VAR,JEST,$(call make-lazy,$(VAR)))

JEST_ARGS ?=


SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	coverage \

SF_TEST_TARGETS := \
	$(SF_TEST_TARGETS) \
	test-jest \

# ------------------------------------------------------------------------------

.PHONY: test-jest
test-jest:
	$(JEST) $(JEST_ARGS)
