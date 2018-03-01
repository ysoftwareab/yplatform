include support-firecloud/repo/mk/js.common.node.mk

# ------------------------------------------------------------------------------

EC_FILES_IGNORE := \
	$(EC_FILES_IGNORE) \
	-e "^bin/" \
	-e "^repo/LICENSE$$" \
	-e "^transcrypt$$" \

# ------------------------------------------------------------------------------

.PHONY: is-decrypted
is-decrypted:
	$(CAT) docs/how-to-manage-secrets.md.test.secret | $(GREP) -q "This is a test of transcrypt."
