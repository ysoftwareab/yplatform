include support-firecloud/repo/mk/js.common.node.mk

# ------------------------------------------------------------------------------

EC_FILES_IGNORE := \
	$(EC_FILES_IGNORE) \
	-e "^bin/" \
	-e "^repo/LICENSE$$" \
	-e "^support-firecloud$$" \
	-e "^transcrypt$$" \

SF_TEST_TARGETS := \
	$(SF_TEST_TARGETS) \
	test-secret \

# ------------------------------------------------------------------------------

.PHONY: test-secret
ifeq (true,$(IS_TRANSCRYPTED))
test-secret:
	$(CAT) docs/how-to-manage-secrets.md.test.secret | \
		$(GREP) -q "This is a test of transcrypt."; \
else
test-secret:
	:
endif
