include support-firecloud/repo/mk/js.common.node.mk

# ------------------------------------------------------------------------------

EC_FILES_IGNORE := \
	$(EC_FILES_IGNORE) \
	-e "^bin/" \
	-e "^repo/LICENSE$$" \
	-e "^transcrypt$$" \

SF_TEST_TARGETS := \
	$(SF_TEST_TARGETS) \
	test-is-decrypted \

# ------------------------------------------------------------------------------

.PHONY: test-is-decrypted
test-is-decrypted:
	$(CAT) docs/how-to-manage-secrets.md.test.secret | $(GREP) -q "This is a test of transcrypt."
