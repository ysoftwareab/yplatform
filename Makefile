ifeq (,$(wildcard support-firecloud/Makefile))
INSTALL_SUPPORT_FIRECLOUD := $(shell ln -s . support-firecloud)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_SUPPORT_FIRECLOUD
endif
endif

include support-firecloud/repo/mk/generic.common.mk
include support-firecloud/repo/mk/js.deps.npm.mk
include support-firecloud/repo/mk/js.check.eslint.mk

# ------------------------------------------------------------------------------

COMMON_MKS := $(wildcard repo/mk/*.common.mk)
# FIXME env.common.mk isn't an "entrypoint" makefile, like the rest
COMMON_MKS := $(filter-out repo/mk/env.common.mk,$(COMMON_MKS))

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	support-firecloud \

SF_PATH_FILES_IGNORE := \
	$(SF_PATH_FILES_IGNORE) \
	-e "^ci/linux/Dockerfile" \
	-e "^generic/dot\.gitattributes_global$$" \
	-e "^generic/dot\.gitignore_global$$" \
	-e "^repo/AUTHORS$$" \
	-e "^repo/Brewfile.inc.sh$$" \
	-e "^repo/cfn/tpl\.Makefile$$" \
	-e "^repo/dot.github/" \
	-e "^repo/LICENSE$$" \
	-e "^repo/NOTICE$$" \
	-e "^repo/UNLICENSE$$" \

SF_ECLINT_FILES_IGNORE := \
	$(SF_ECLINT_FILES_IGNORE) \
	-e "^bin/" \
	-e "^repo/LICENSE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^support-firecloud$$" \

GITHUB_WORKFLOWS := \
	.github/workflows/main.yml \

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	$(GITHUB_WORKFLOWS) \

SF_TEST_TARGETS := \
	$(SF_TEST_TARGETS) \
	test-secret \
	test-upload-job-artifacts \
	test-repo-mk \
	test-github-workflows \

# ------------------------------------------------------------------------------

.github/workflows/main.yml: .github/workflows/.main.src.yml
	(echo "# WARNING: DO NOT EDIT. AUTO-GENERATED CODE ($<)"; cat $< | bin/yaml-expand) > $@


.PHONY: test-secret
test-secret:
ifeq ($(SF_IS_TRANSCRYPTED),true)
	$(CAT) doc/how-to-manage-secrets.md.test.secret | \
		$(GREP) -q "This is a test of transcrypt."
else
	:
endif


.PHONY: test-upload-job-artifacts
test-upload-job-artifacts:
	$(ECHO) "This is a test of upload-job-artifacts" >some-job-artifact.md


.PHONY: test-repo-mk
test-repo-mk:
	$(MAKE) help
	for mk in $(COMMON_MKS); do \
		$(ECHO_DO) "Testing $${mk}..."; \
		$(MAKE) -f $${mk} help; \
		$(ECHO_DONE); \
	done


.PHONY: test-github-workflows
test-github-workflows:
	for GITHUB_WORKFLOW in $(GITHUB_WORKFLOWS); do \
		$(MAKE) $${GITHUB_WORKFLOW}; \
		$(GIT) diff --exit-code $${GITHUB_WORKFLOW} || { \
			$(ECHO_ERR) "$${GITHUB_WORKFLOW} has uncommitted changes."; \
			exit 1; \
		} \
	done
