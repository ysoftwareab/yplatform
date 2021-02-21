ifeq (,$(wildcard support-firecloud/Makefile))
INSTALL_SUPPORT_FIRECLOUD := $(shell ln -s . support-firecloud)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_SUPPORT_FIRECLOUD
endif
endif

include support-firecloud/build.mk/generic.common.mk
include support-firecloud/build.mk/sh.check.shellcheck.mk
include support-firecloud/build.mk/js.deps.npm.mk
include support-firecloud/build.mk/js.deps.yarn.mk
include support-firecloud/build.mk/js.check.eslint.mk
include support-firecloud/build.mk/core.misc.release.tag.mk

# ------------------------------------------------------------------------------

RAW_GUC_URL := https://raw.githubusercontent.com
BREWFILE_LOCK := $(GIT_ROOT)/Brewfile.lock

# for testing purposes, so that 'make docker-ci' works
# otherwise SF_DOCKER_CI_IMAGE=false (set in .ci.main.sh)
SF_DOCKER_CI_IMAGE := rokmoln/sf-ubuntu-bionic-minimal

BREW = $(call which,BREW,brew)
$(foreach VAR,BREW,$(call make-lazy,$(VAR)))

COMMON_MKS := $(wildcard build.mk/*.common.mk)
COMMON_MKS := $(filter-out build.mk/generic.common.mk,$(COMMON_MKS))

FORMULA_PATCH_FILES = $(shell $(GIT_LS) "Formula/*.patch")
FORMULA_PATCHED_FILES = $(patsubst %.original.rb,%.rb,$(shell $(GIT_LS) "Formula/patch-src/*.original.rb"))

SF_CLEAN_FILES += \
	support-firecloud \

SF_VENDOR_FILES_IGNORE += \
	-e "^Formula/.*\.patch$$" \
	-e "^Formula/patch-src/" \
	-e "^bin/aws-cfviz$$" \
	-e "^bin/transcrypt$$" \
	-e "^bin/travis-wait$$" \
	-e "^bootstrap/brew-util/homebrew-install\.sh$$" \
	-e "^bootstrap/brew-util/homebrew-install\.sh\.patch$$" \
	-e "^doc/bak/" \

SF_PATH_FILES_IGNORE += \
	-e "^Formula/" \
	-e "^aws-cfn.mk/tpl\.Makefile$$" \
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
	-e "^bin/" \
	-e "^gitconfig/dot.gitignore_global$$" \
	-e "^gitconfig/dot.gitignore_global.base$$" \
	-e "^repo/LICENSE$$" \
	-e "^repo/UNLICENSE$$" \
	-e "^support-firecloud$$" \

SF_SHELLCHECK_FILES_IGNORE += \
	-e "^doc/ci\-sh\.md$$" \

SF_CHECK_TPL_FILES += \
	$(FORMULA_PATCHED_FILES) \
	$(FORMULA_PATCH_FILES) \
	.github/workflows/main.yml \
	Formula/editoconfig-checker.rb \
	gitconfig/dot.gitignore_global \

ifeq (true,$(CI))
.PHONY: $(sf_CHECK_TPL_FILES)
endif

SF_DEPS_TARGETS += \
	.github/workflows/main.yml \

SF_TEST_TARGETS += \
	test-secret \
	test-upload-job-artifacts \
	test-repo-mk \
	test-gitignore \

# ------------------------------------------------------------------------------

.github/workflows/main.yml: .github/workflows/main.yml.tpl .github/workflows.src/main.yml
	$(call sf-generate-from-template)


Formula/editorconfig-checker.rb: Formula/editorconfig-checker.rb.tpl
	$(call sf-generate-from-template)


.PHONY: test-secret
test-secret:
ifeq ($(SF_IS_TRANSCRYPTED),true)
	$(CAT) doc/how-to-manage-secrets.md.test.secret
	$(CAT) doc/how-to-manage-secrets.md.test.secret | \
		$(GREP) -q "This is a test of transcrypt."
else
	:
endif


.PHONY: test-upload-job-artifacts
test-upload-job-artifacts:
	$(ECHO) "This is a test of upload-job-artifacts" >some-job-artifact.md


.PHONY: test-gitignore
test-gitignore:
	$(CAT) .gitignore | $(GREP) -q -Fx "/some-job-artifact.md"
	$(GIT) check-ignore --verbose some-job-artifact.md | $(CUT) -d: -f1 | $(GREP) -q -Fx ".gitignore"
	$(CAT) gitconfig/dot.gitignore_global | $(GREP) -q -Fx "Makefile.lazy"
	$(GIT) check-ignore --verbose Makefile.lazy | $(CUT) -d: -f1 | $(GREP) -q -Fx ".git/info/exclude"


.PHONY: test-repo-mk
test-repo-mk:
	$(MAKE) help
	for mk in $(COMMON_MKS); do \
		$(ECHO_DO) "Testing $${mk}..."; \
		$(MAKE) -f build.mk/generic.common.mk -f $${mk} help; \
		$(ECHO_DONE); \
	done


gitconfig/dot.gitignore_global: gitconfig/dot.gitignore_global.tpl gitconfig/dot.gitignore_global.base ## Regenerate gitconfig/dot.gitignore_global.
	$(call sf-generate-from-template)


bootstrap/brew-util/homebrew-install.sh: Brewfile.lock ## Regenerate bootstrap/brew-util/homebrew-install.sh
	$(eval BREW_INSTALL_GITREF := $(shell $(CAT) $(BREWFILE_LOCK) | $(GREP) "^homebrew/install " | $(CUT) -d" " -f2 || $(ECHO) "master"))
	$(CURL) -o $@.original $(RAW_GUC_URL)/Homebrew/install/$(BREW_INSTALL_GITREF)/install.sh
	if [[ -f "$@.patch" ]]; then \
		$(CAT) $@.patch | $(PATCH) $@.original -o $@; \
	else \
		$(CP) $@.original $@; \
	fi
	$(EDITOR) $@
	$(DIFF) -u --label $@.original --label $@ $@.original $@ > $@.patch || true


.PHONY: Formula/patch-src/%.original.rb
Formula/patch-src/%.original.rb:
	# see https://discourse.brew.sh/t/how-to-tap-homebrew-linuxbrew-core-on-macos/8731/3
	if [[ "$(OS_SHORT)" = "darwin" ]]; then \
		$(CURL) -q -fsSL https://raw.githubusercontent.com/homebrew/linuxbrew-core/master/Formula/$*.rb -o $@; \
	else \
		$(BREW) cat $* > $@; \
	fi
	if [[ -f Formula/$*.linux.patch ]]; then \
		$(MAKE) Formula/patch-src/$*.rb || { \
			$(ECHO_ERR) "Failed to apply old patch Formula/$*.linux.patch and update patched file Formula/patch-src/$*.rb."; \
			exit 1; \
		} \
	else \
		$(CP) Formula/patch-src/$*.original.rb Formula/patch-src/$*.rb; \
	fi
	$(EDITOR) Formula/patch-src/$*.rb
	$(MAKE) Formula/$*.linux.patch


.PHONY: Formula/%.linux.patch
Formula/%.linux.patch: Formula/patch-src/%.original.rb
	$(call sf-generate-from-template-patch,Formula/patch-src/$*.rb)


.PHONY: Formula/patch-src/%.rb
Formula/patch-src/%.rb: Formula/patch-src/%.original.rb
	$(call sf-generate-from-template-patched,Formula/$*.linux.patch)
