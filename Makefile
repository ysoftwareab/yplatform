# include support-firecloud/repo/mk/js.common.node.mk
include repo/mk/js.common.node.mk

# ------------------------------------------------------------------------------

SF_PATH_FILES_IGNORE := \
	$(SF_PATH_FILES_IGNORE) \
	-e "^generic/dot\.gitattributes_global" \
	-e "^generic/dot\.gitignore_global" \
	-e "^repo/AUTHORS$$" \
	-e "^repo/Brewfile.inc.sh$$" \
	-e "^repo/LICENSE$$" \
	-e "^repo/NOTICE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^repo/cfn/tpl\.Makefile$$" \

SF_ECLINT_FILES_IGNORE := \
	$(SF_ECLINT_FILES_IGNORE) \
	-e "^bin/" \
	-e "^repo/LICENSE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^support-firecloud$$" \

SF_TEST_TARGETS := \
	$(SF_TEST_TARGETS) \
	test-secret \
	test-upload-job-artifacts \

# ------------------------------------------------------------------------------

.PHONY: test-secret
test-secret:
ifeq (true,$(SF_IS_TRANSCRYPTED))
	$(CAT) doc/how-to-manage-secrets.md.test.secret | \
		$(GREP) -q "This is a test of transcrypt."; \
else
	:
endif

.PHONY: test-upload-job-artifacts
test-upload-job-artifacts:
	$(ECHO) "This is a test of upload-job-artifacts" >some-job-artifact.md
