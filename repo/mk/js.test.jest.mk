# Adds 'test/**/*.test.js' targets to run jest on a specific test/**/*.test.js file.
#
# ------------------------------------------------------------------------------
#
# Adds a 'test-jest' internal target to run all SF_JEST_TEST_FILES (defaults to test/**/*.test.js).
# The 'test-jest' target is automatically included in the 'test' target via SF_TEST_TARGETS.
#
# The jest executable is lazy-found inside ./node_modules/.bin and $PATH.
# The arguments to the jest executable can be changed via JEST_ARGS.
#
# ------------------------------------------------------------------------------

JEST = $(call npm-which,JEST,jest)
$(foreach VAR,JEST,$(call make-lazy,$(VAR)))

JEST_ARGS += \

SF_JEST_TEST_FILES += \
	$(shell $(FIND_Q_NOSYM) test -type f -name "*.test.js" -print) \

SF_PATH_FILES_IGNORE += \
	-e "/__mocks__/" \
	-e "/__snapshots__/" \

SF_CLEAN_FILES += \
	coverage \

SF_TEST_TARGETS += \
	test-jest \

# ------------------------------------------------------------------------------

.PHONY: test-jest
test-jest:
	[[ "$(words $(JEST_TEST_FILES))" = "0" ]] || { \
		$(JEST) $(JEST_ARGS); \
	}


.PHONY: $(SF_JEST_TEST_FILES)
$(SF_JEST_TEST_FILES):
	$(JEST) $(JEST_ARGS) $@
