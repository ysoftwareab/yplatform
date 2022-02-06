# Adds 'test/**/*.test.js' targets to run jest on a specific test/**/*.test.js file.
#
# ------------------------------------------------------------------------------
#
# Adds a 'test-jest' internal target to run all YP_JEST_TEST_FILES (defaults to test/**/*.test.js).
# The 'test-jest' target is automatically included in the 'test' target via YP_TEST_TARGETS.
#
# The jest executable is lazy-found inside ./node_modules/.bin and $PATH.
# The arguments to the jest executable can be changed via JEST_ARGS.
#
# ------------------------------------------------------------------------------

JEST = $(call npm-which,JEST,jest)
$(foreach VAR,JEST,$(call make-lazy-once,$(VAR)))

JEST_ARGS += \

YP_JEST_TEST_FILES += \
	$(shell $(FIND_Q_NOSYM) test -type f -name "*.test.js" -print) \

YP_VENDOR_FILES_IGNORE += \
	-e "/__mocks__/" \
	-e "/__snapshots__/" \

YP_CLEAN_FILES += \
	coverage \

YP_TEST_TARGETS += \
	test-jest \

# ------------------------------------------------------------------------------

.PHONY: test-jest
test-jest:
	YP_JEST_TEST_FILES_TMP=($(YP_JEST_TEST_FILES)); \
	[[ "$${#YP_JEST_TEST_FILES_TMP[@]}" = "0" ]] || { \
		$(JEST) $(JEST_ARGS); \
	}


.PHONY: $(YP_JEST_TEST_FILES)
$(YP_JEST_TEST_FILES):
	$(JEST) $(JEST_ARGS) $@
