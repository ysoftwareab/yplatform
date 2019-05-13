JEST = $(call npm-which,JEST,jest)
$(foreach VAR,JEST,$(call make-lazy,$(VAR)))

JEST_ARGS ?=

JEST_TEST_FILES := $(shell $(FIND_Q_NOSYM) test -type f -name "*.test.js" -print)

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


.PHONY: $(JEST_TEST_FILES)
$(JEST_TEST_FILES):
	$(JEST) $(JEST_ARGS) $@
