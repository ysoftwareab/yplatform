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

FORMULA_PATCH_FILES = $(shell $(GIT_LS) "Formula/*.patch")
FORMULA_PATCHED_FILES = $(patsubst %.original.rb,%.rb,$(shell $(GIT_LS) "Formula/patch-src/*.original.rb"))

YP_CLEAN_FILES += \
	yplatform \

YP_VENDOR_FILES_IGNORE += \
	-e "^Formula/.*\.patch$$" \
	-e "^Formula/patch-src/" \
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
	-e "^Formula/" \
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
	-e "^\.github/workflows/deployc\.yml$$" \
	-e "^\.github/workflows/main\.yml$$" \
	-e "^\.github/workflows/mainc\.yml$$" \
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
	.devcontainer/devcontainer.json \
	.github/workflows/main.yml \
	.github/workflows/mainc.yml \
	.github/workflows/deployc.yml \
	.gitpod.yml \
	gitconfig/dot.gitignore_global \

ifeq (true,$(CI))
.PHONY: $(YP_CHECK_TPL_FILES)
endif

YP_DEPS_TARGETS += \
	.devcontainer/devcontainer.json \
	.github/workflows/main.yml \
	.github/workflows/mainc.yml \
	.github/workflows/deployc.yml \
	.gitpod.yml \

# NOTE check-shellcheck is slow, and skip it during 'git push' hook, unless on master branch
ifeq (true,$(YP_GIT_HOOK))
ifneq (master,$(GIT_BRANCH))
YP_CHECK_TARGETS := $(filter-out check-shellcheck,$(YP_CHECK_TARGETS))
endif
endif

YP_TEST_TARGETS += \
	test-secret \
	test-upload-job-artifacts \
	test-repo-mk \
	test-gitignore \
	test-env-ci \
	test-env-ci-unknown \

# ------------------------------------------------------------------------------

.devcontainer/devcontainer.json: yplatform/package.json
.devcontainer/devcontainer.json: .vscode/extensions.json
.devcontainer/devcontainer.json: .devcontainer/devcontainer.json.tpl
	$(eval export YP_DOCKER_CI_IMAGE)
	$(call yp-generate-from-template)


.github/workflows/main.yml: bin/github-checkout
.github/workflows/main.yml: $(wildcard .github/workflows.src/common*)
.github/workflows/main.yml: $(wildcard .github/workflows.src/main*)
.github/workflows/main.yml: .github/workflows/main.yml.tpl
	$(call yp-generate-from-template)


.github/workflows/mainc.yml: bin/github-checkout
.github/workflows/mainc.yml: $(wildcard .github/workflows.src/common*)
.github/workflows/mainc.yml: $(wildcard .github/workflows.src/mainc*)
.github/workflows/mainc.yml: .github/workflows/mainc.yml.tpl
	$(call yp-generate-from-template)


.github/workflows/deployc.yml: bin/github-checkout
.github/workflows/deployc.yml: $(wildcard .github/workflows.src/common*)
.github/workflows/deployc.yml: $(wildcard .github/workflows.src/deployc*)
.github/workflows/deployc.yml: .github/workflows/deployc.yml.tpl
	$(call yp-generate-from-template)


.gitpod.yml: yplatform/package.json
.gitpod.yml: .vscode/extensions.json
.gitpod.yml: .gitpod.yml.tpl
	$(eval export YP_DOCKER_CI_IMAGE)
	$(call yp-generate-from-template)


Formula/editorconfig-checker.rb: Formula/editorconfig-checker.rb.tpl
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


.PHONY: Formula/patch-src/%.original.rb
ifneq (true,$(CI))
Formula/patch-src/%.original.rb: $(BREWFILE_LOCK)
endif
Formula/patch-src/%.original.rb:
	$(eval HOMEBREW_CORE_GIT_REF := $(shell $(CAT) $(BREWFILE_LOCK) | \
		$(GREP) "^homebrew/homebrew-core" | $(CUT) -d" " -f2))
	$(CURL) -q -fsSL \
		https://raw.githubusercontent.com/homebrew/homebrew-core/$(HOMEBREW_CORE_GIT_REF)/Formula/$*.rb -o $@
	if [[ -f Formula/$*.linux.patch ]]; then \
		$(MAKE) Formula/patch-src/$*.rb || { \
			$(ECHO_ERR) "Failed to apply old patch Formula/$*.linux.patch and update patched file Formula/patch-src/$*.rb."; \
			exit 1; \
		} \
	else \
		$(CP) Formula/patch-src/$*.original.rb Formula/patch-src/$*.rb; \
	fi
	if [[ -t 0 ]] && [[ -t 1 ]]; then \
		$(EDITOR) Formula/patch-src/$*.rb; \
	else \
		$(ECHO_INFO) "No tty."; \
		$(ECHO_SKIP) "$(EDITOR) Formula/patch-src/$*.rb"; \
	fi
	$(MAKE) Formula/$*.linux.patch


.PHONY: Formula/%.linux.patch
Formula/%.linux.patch: Formula/patch-src/%.original.rb
	$(call yp-generate-from-template-patch,Formula/patch-src/$*.rb)


.PHONY: Formula/patch-src/%.rb
Formula/patch-src/%.rb: Formula/patch-src/%.original.rb
	$(call yp-generate-from-template-patched,Formula/$*.linux.patch)
