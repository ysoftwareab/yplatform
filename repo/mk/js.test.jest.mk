JEST = $(call which,JEST,jest)

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	coverage \

SF_TEST_TARGETS := \
	$(SF_TEST_TARGETS) \
	test-jest \

# ------------------------------------------------------------------------------

.PHONY: test-jest
test-jest:
	$(JEST)
