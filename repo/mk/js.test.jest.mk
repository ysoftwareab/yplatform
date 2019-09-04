# Adds 'test/**/*.test.js' targets to run jest on a specific test/**/*.test.js file.
#
# ------------------------------------------------------------------------------
#
# Adds a 'test-jest' internal target to run all JEST_TEST_FILES (defaults to test/**/*.test.js).
# The 'test-jest' target is automatically included in the 'test' target via SF_TEST_TARGETS.
#
# The jest executable is lazy-found inside ./node_modules/.bin and $PATH.
# The arguments to the jest executable can be changed via JEST_ARGS.
#
# ------------------------------------------------------------------------------

JEST = $(call npm-which,JEST,jest)
$(foreach VAR,JEST,$(call make-lazy,$(VAR)))

JEST_ARGS += \

JEST_TEST_FILES += \
	$(shell $(FIND_Q_NOSYM) test -type f -name "*.test.js" -print) \

SF_CLEAN_FILES += \
	coverage \

SF_TEST_TARGETS += \
	test-jest \

# ------------------------------------------------------------------------------

.PHONY: test-jest
test-jest:
	$(JEST) $(JEST_ARGS)


.PHONY: $(JEST_TEST_FILES)
$(JEST_TEST_FILES):
	$(JEST) $(JEST_ARGS) $@
