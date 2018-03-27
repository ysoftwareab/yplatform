include support-firecloud/repo/mk/js.common.node.mk

# ------------------------------------------------------------------------------

PATH_FILES_IGNORE := \
	$(PATH_FILES_IGNORE) \
	-e "^generic/dot.gitattributes_global" \
	-e "^generic/dot.gitignore_global" \
	-e "^repo/AUTHORS$$" \
	-e "^repo/LICENSE$$" \
	-e "^repo/NOTICE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^repo/cfn/tpl.Makefile$$" \

EC_FILES_IGNORE := \
	$(EC_FILES_IGNORE) \
	-e "^bin/" \
	-e "^repo/LICENSE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^support-firecloud$$" \

SF_TEST_TARGETS := \
	$(SF_TEST_TARGETS) \
	test-secret \

# ------------------------------------------------------------------------------

.PHONY: test-secret
ifeq (true,$(IS_TRANSCRYPTED))
test-secret:
	$(CAT) doc/how-to-manage-secrets.md.test.secret | \
		$(GREP) -q "This is a test of transcrypt."; \
else
test-secret:
	:
endif
