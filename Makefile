ifeq (,$(wildcard support-firecloud/Makefile))
INSTALL_SUPPORT_FIRECLOUD := $(shell ln -s . support-firecloud)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_SUPPORT_FIRECLOUD
endif
endif

include support-firecloud/build.mk/generic.common.mk
include support-firecloud/build.mk/sh.check.shellcheck.mk
include support-firecloud/build.mk/js.deps.npm.mk
include support-firecloud/build.mk/js.check.eslint.mk
include support-firecloud/build.mk/core.misc.release.tag.mk

# ------------------------------------------------------------------------------

RAW_GUC_URL := https://raw.githubusercontent.com
BREWFILE_LOCK := Brewfile.lock

# for testing purposes, so that 'make docker-ci' works
# otherwise SF_DOCKER_CI_IMAGE=false (set in .ci.main.sh)
SF_DOCKER_CI_IMAGE := rokmoln/sf-ubuntu-bionic-minimal

BREW = $(call which,BREW,brew)
$(foreach VAR,BREW,$(call make-lazy,$(VAR)))
NODE_ENV_CI := $(SUPPORT_FIRECLOUD_DIR)/bin/node-env-ci
CI_PRINTVARS := $(SUPPORT_FIRECLOUD_DIR)/bin/ci-printvars

COMMON_MKS := $(wildcard build.mk/*.common.mk)
COMMON_MKS := $(filter-out build.mk/generic.common.mk,$(COMMON_MKS))

SF_CLEAN_FILES += \
	support-firecloud \

SF_VENDOR_FILES_IGNORE += \
	-e "^bin/aws-cfviz$$" \
	-e "^bin/git-archive-all$$" \
	-e "^bin/transcrypt$$" \
	-e "^bin/travis-wait$$" \
	-e "^bin/urldecode$$" \
	-e "^bin/urlencode$$" \
	-e "^bootstrap/brew-util/homebrew-install\.sh$$" \
	-e "^bootstrap/brew-util/homebrew-install\.sh\.patch$$" \
	-e "^doc/bak/" \

SF_PATH_FILES_IGNORE += \
	-e "^aws-cfn.mk/tpl\.Makefile$$" \
	-e "^dockerfiles/build.FROM_DOCKER_IMAGE_TAG$$" \
	-e "^generic/dot\.gitattributes_global$$" \
	-e "^generic/dot\.gitignore_global$$" \
	-e "^gitconfig/dot\.gitattributes_global$$" \
	-e "^gitconfig/dot\.gitignore_global$$" \
	-e "^gitconfig/dot\.gitignore_global\.base$$" \
	-e "^gitconfig/dot\.gitignore_global\.tpl$$" \
	-e "^repo/AUTHORS$$" \
	-e "^repo/Brewfile.inc.sh$$" \
	-e "^repo/LICENSE$$" \
	-e "^repo/NOTICE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^repo/dot.github/" \

SF_ECLINT_FILES_IGNORE += \
	-e "^\.github/workflows/deploy\.yml$$" \
	-e "^\.github/workflows/main\.yml$$" \
	-e "^\.travis\.yml\.bak$$" \
	-e "^bin/" \
	-e "^gitconfig/dot.gitignore_global$$" \
	-e "^gitconfig/dot.gitignore_global.base$$" \
	-e "^release\-notes/" \
	-e "^repo/LICENSE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^support-firecloud$$" \

SF_SHELLCHECK_FILES_IGNORE += \
	-e "^doc/ci\-sh\.md$$" \

SF_CHECK_TPL_FILES += \
	$(FORMULA_PATCHED_FILES) \
	$(FORMULA_PATCH_FILES) \
	.github/workflows/main.yml \
	.github/workflows/deploy.yml \
	homebrew/Formula/editorconfig-checker.rb \
	gitconfig/dot.gitignore_global \

ifeq (true,$(CI))
.PHONY: $(sf_CHECK_TPL_FILES)
endif

SF_DEPS_TARGETS += \
	.github/workflows/main.yml \
	.github/workflows/deploy.yml \

SF_TEST_TARGETS += \
	test-secret \
	test-upload-job-artifacts \
	test-repo-mk \
	test-gitignore \
	test-env-ci \
	test-env-ci-unknown \

# ------------------------------------------------------------------------------

.github/workflows/main.yml: bin/github-checkout $(wildcard .github/workflows.src/main*)
.github/workflows/main.yml: .github/workflows/main.yml.tpl
	$(call sf-generate-from-template)


.github/workflows/deploy.yml: bin/github-checkout $(wildcard .github/workflows.src/deploy*)
.github/workflows/deploy.yml: .github/workflows/deploy.yml.tpl
	$(call sf-generate-from-template)


homebrew/Formula/editorconfig-checker.rb: homebrew/Formula/editorconfig-checker.rb.tpl
	$(call sf-generate-from-template)


.PHONY: test-secret
test-secret:
ifeq ($(SF_IS_TRANSCRYPTED),true)
	$(ECHO_DO) "Testing transcrypt..."
	$(CAT) doc/how-to-manage-secrets.md.test.secret
	$(CAT) doc/how-to-manage-secrets.md.test.secret | \
		$(GREP) -q "This is a test of transcrypt."
	$(ECHO_DONE)
else
	:
endif


.PHONY: test-upload-job-artifacts
test-upload-job-artifacts:
	$(ECHO_DO) "Testing upload-job-artifacts..."
	$(ECHO) "This is a test of upload-job-artifacts" >some-job-artifact.md
	$(ECHO_DONE)


.PHONY: test-gitignore
test-gitignore:
	$(ECHO_DO) "Testing .gitignore..."
	$(CAT) .gitignore | $(GREP) -q -Fx "/some-job-artifact.md"
	$(GIT) check-ignore --verbose some-job-artifact.md | $(CUT) -d: -f1 | $(GREP) -q -Fx ".gitignore"
	$(CAT) gitconfig/dot.gitignore_global | $(GREP) -q -Fx "Makefile.lazy"
	$(GIT) check-ignore --verbose Makefile.lazy | $(CUT) -d: -f1 | $(GREP) -q -Fx ".git/info/exclude"
	$(ECHO_DONE)


.PHONY: test-env-ci
test-env-ci:
	$(ECHO_DO) "Testing that we are in sync with env-ci..."
	$(COMM) -23 <($(NODE_ENV_CI) --sf | $(SORT)) <($(CI_PRINTVARS) --sf | $(SORT)) | \
		$(SUPPORT_FIRECLOUD_DIR)/bin/ifne --not --fail --print-on-fail || { \
			$(ECHO_ERR) "Found the above differences with env-ci."; \
			$(ECHO_INFO) "A full diff between SF_CI_* env vars between bin/env-ci and bin/ci-printvars follows:"; \
			$(DIFF) --unified=1000000 --label node-env-ci --label ci-printvars \
				<($(NODE_ENV_CI) --sf | $(SORT)) <($(CI_PRINTVARS) --sf | $(SORT)) || true; \
			$(ECHO_INFO) "A full printout of CI env vars follows:"; \
			$(CI_PRINTVARS) | $(SORT); \
			exit 1; \
		}
	$(ECHO_DONE)


.PHONY: test-env-ci-unknown
test-env-ci-unknown:
	$(ECHO_DO) "Testing that we there are no new environment variables in CI..."
	$(CI_PRINTVARS) --unknown
	$(CI_PRINTVARS) --unknown --sf
	$(ECHO_DONE)


.PHONY: test-repo-mk
test-repo-mk:
	$(ECHO_DO) "Testing 'make help' and makefiles in build.mk..."
	$(MAKE) help
	for mk in $(COMMON_MKS); do \
		$(ECHO_DO) "Testing $${mk}..."; \
		$(MAKE) -f build.mk/generic.common.mk -f $${mk} help; \
		$(ECHO_DONE); \
	done
	$(ECHO_DONE)


gitconfig/dot.gitignore_global: ## Regenerate gitconfig/dot.gitignore_global.
gitconfig/dot.gitignore_global: gitconfig/dot.gitignore_global.base
gitconfig/dot.gitignore_global: gitconfig/dot.gitignore_global.tpl
	$(call sf-generate-from-template)


include Makefile.homebrew
