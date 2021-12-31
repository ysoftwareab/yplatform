ifeq (,$(wildcard yplatform/Makefile))
INSTALL_YP := $(shell ln -s . yplatform)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_YP
endif
endif

include yplatform/build.mk/generic.common.mk
include yplatform/build.mk/sh.check.shellcheck.mk
include yplatform/build.mk/js.deps.npm.mk
include yplatform/build.mk/js.check.eslint.mk
include yplatform/build.mk/core.misc.release.tag.mk

# ------------------------------------------------------------------------------

RAW_GUC_URL := https://raw.githubusercontent.com
BREWFILE_LOCK := Brewfile.lock

# for testing purposes, so that 'make docker-ci' works
# otherwise YP_DOCKER_CI_IMAGE=false (set in .ci.main.sh)
YP_DOCKER_CI_IMAGE := ysoftwareab/yp-ubuntu-20.04-minimal

BREW = $(call which,BREW,brew)
$(foreach VAR,BREW,$(call make-lazy,$(VAR)))
NODE_ENV_CI := $(YP_DIR)/bin/node-env-ci
CI_PRINTVARS := $(YP_DIR)/bin/ci-printvars

COMMON_MKS := $(wildcard build.mk/*.common.mk)
COMMON_MKS := $(filter-out build.mk/generic.common.mk,$(COMMON_MKS))

YP_CLEAN_FILES += \
	yplatform \

SF_VENDOR_FILES_IGNORE += \
	-e "^bin/aws-cfviz$$" \
	-e "^bin/git-archive-all$$" \
	-e "^bin/retry$$" \
	-e "^bin/transcrypt$$" \
	-e "^bin/travis-wait$$" \
	-e "^bin/urldecode$$" \
	-e "^bin/urlencode$$" \
	-e "^bin/wait-for$$" \
	-e "^bootstrap/brew-util/homebrew-install\.sh$$" \
	-e "^bootstrap/brew-util/homebrew-install\.sh\.original$$" \
	-e "^bootstrap/brew-util/homebrew-install\.sh\.patch$$" \
	-e "^doc/bak/" \

YP_SYMLINK_FILES_IGNORE += \
	-e "^repo/dot\.git-hooks/pre-push$$" \

YP_PATH_FILES_IGNORE += \
	-e "^aws-cfn.mk/tpl\.Makefile$$" \
	-e "^dockerfiles/build.FROM_DOCKER_IMAGE_TAG$$" \
	-e "^generic/dot\.gitattributes_global$$" \
	-e "^generic/dot\.gitignore_global$$" \
	-e "^gitconfig/dot\.gitattributes_global$$" \
	-e "^gitconfig/dot\.gitattributes_global\.base" \
	-e "^gitconfig/dot\.gitattributes_global\.tpl$$" \
	-e "^gitconfig/dot\.gitignore_global$$" \
	-e "^gitconfig/dot\.gitignore_global\.base$$" \
	-e "^gitconfig/dot\.gitignore_global\.tpl$$" \
	-e "^repo/AUTHORS$$" \
	-e "^repo/Brewfile.inc.sh$$" \
	-e "^repo/LICENSE$$" \
	-e "^repo/NOTICE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^repo/dot\.github/" \
	-e "^sshconfig/known_hosts\." \

YP_ECLINT_FILES_IGNORE += \
	-e "^\.github/workflows/deploy\.yml$$" \
	-e "^\.github/workflows/main\.yml$$" \
	-e "^\.travis\.yml\.bak$$" \
	-e "^bin/" \
	-e "^gitconfig/dot.gitignore_global$$" \
	-e "^gitconfig/dot.gitignore_global.base$$" \
	-e "^release\-notes/" \
	-e "^repo/LICENSE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^yplatform$$" \

YP_SHELLCHECK_FILES_IGNORE += \
	-e "^doc/ci\-sh\.md$$" \

YP_CHECK_TPL_FILES += \
	$(FORMULA_PATCHED_FILES) \
	$(FORMULA_PATCH_FILES) \
	.github/workflows/main.yml \
	.github/workflows/deploy.yml \
	gitconfig/dot.gitignore_global \

ifeq (true,$(CI))
.PHONY: $(yp_CHECK_TPL_FILES)
endif

YP_DEPS_TARGETS += \
	.github/workflows/main.yml \
	.github/workflows/deploy.yml \

YP_TEST_TARGETS += \
	test-secret \
	test-upload-job-artifacts \
	test-repo-mk \
	test-gitignore \
	test-env-ci \
	test-env-ci-unknown \

# ------------------------------------------------------------------------------

.github/workflows/main.yml: bin/github-checkout $(wildcard .github/workflows.src/main*)
.github/workflows/main.yml: .github/workflows/main.yml.tpl
	$(call yp-generate-from-template)


.github/workflows/deploy.yml: bin/github-checkout $(wildcard .github/workflows.src/deploy*)
.github/workflows/deploy.yml: .github/workflows/deploy.yml.tpl
	$(call yp-generate-from-template)


.PHONY: test-secret
test-secret:
ifeq ($(YP_IS_TRANSCRYPTED),true)
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
	$(COMM) -23 <($(NODE_ENV_CI) --yp | $(SORT)) <($(CI_PRINTVARS) --yp | $(SORT)) | \
		$(YP_DIR)/bin/ifne --not --fail --print-on-fail || { \
			$(ECHO_ERR) "Found the above differences with env-ci."; \
			$(ECHO_INFO) "A full diff between YP_CI_* env vars between bin/env-ci and bin/ci-printvars follows:"; \
			$(DIFF) --unified=1000000 --label node-env-ci --label ci-printvars \
				<($(NODE_ENV_CI) --yp | $(SORT)) <($(CI_PRINTVARS) --yp | $(SORT)) || true; \
			$(ECHO_INFO) "A full printout of CI env vars follows:"; \
			$(CI_PRINTVARS) | $(SORT); \
			exit 1; \
		}
	$(ECHO_DONE)


.PHONY: test-env-ci-unknown
test-env-ci-unknown:
	$(ECHO_DO) "Testing that we there are no new environment variables in CI..."
	$(CI_PRINTVARS) --unknown
	$(CI_PRINTVARS) --unknown --yp
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


gitconfig/dot.gitattributes_global: ## Regenerate gitconfig/dot.gitattributes_global.
gitconfig/dot.gitattributes_global: $(wildcard gitconfig/dot.gitattributes_global.base*)
gitconfig/dot.gitattributes_global: gitconfig/dot.gitattributes_global.tpl
	$(call yp-generate-from-template)


gitconfig/dot.gitignore_global: ## Regenerate gitconfig/dot.gitignore_global.
gitconfig/dot.gitignore_global: gitconfig/dot.gitignore_global.base
gitconfig/dot.gitignore_global: gitconfig/dot.gitignore_global.tpl
	$(call yp-generate-from-template)


bootstrap/brew-util/homebrew-install.sh: ## Regenerate bootstrap/brew-util/homebrew-install.sh
ifneq (true,$(CI))
bootstrap/brew-util/homebrew-install.sh: $(BREWFILE_LOCK)
endif
bootstrap/brew-util/homebrew-install.sh:
	$(eval BREW_INSTALL_GIT_REF := $(shell $(CAT) $(BREWFILE_LOCK) | $(GREP) "^homebrew/install " | $(CUT) -d" " -f2 || $(ECHO) "master")) # editorconfig-checker-disable-line
	$(CURL) -o $@.original $(RAW_GUC_URL)/Homebrew/install/$(BREW_INSTALL_GIT_REF)/install.sh
	if [[ -f "$@.patch" ]]; then \
		$(CAT) $@.patch | $(PATCH) $@.original -o $@; \
	else \
		$(CP) $@.original $@; \
	fi
	if [[ -t 0 ]] && [[ -t 1 ]]; then \
		$(EDITOR) $@; \
	else \
		$(ECHO_INFO) "No tty."; \
		$(ECHO_SKIP) "$(EDITOR) $@"; \
	fi
	$(MAKE) $@.patch


PHONY: bootstrap/brew-util/homebrew-install.sh.patch
bootstrap/brew-util/homebrew-install.sh.patch: bootstrap/brew-util/homebrew-install.sh.original
bootstrap/brew-util/homebrew-install.sh.patch: bootstrap/brew-util/homebrew-install.sh
	$(DIFF) -u --label $< --label $(word 2,$^) $< $(word 2,$^) > $@ || true

include Makefile.homebrew
