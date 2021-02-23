# Adds a 'release' target as an alias to 'release/bugfix'.
#
# ------------------------------------------------------------------------------
#
# Adds 'release/bugfix', 'release/feature' and 'release/breaking' targets
# to release new versions with the version bumped accordingly.
# For pre-public <1.0.0 versions:
# * 'breaking' will bump the minor version,
# * 'feature' and 'bugfix' will bump the patch version.
# For public >=1.0.0 versions:
# * 'breaking' will bump the major version,
# * 'feature' will bump the minor version,
# * 'bugfix' will bump the patch version.
#
# ------------------------------------------------------------------------------
#
# Adds a 'release/public' target that is to be used
# once and only once in the lifecycle of a package.
# Going public semver-wise is a matter of code maturity and API stability,
# and not a matter of transitioning the package from internal/private to public.
#
# ------------------------------------------------------------------------------
#
# Adds a 'release/v<SEMVER>' target to release a specific version.
# Version will be set to the given SEMVER value.
#
# ------------------------------------------------------------------------------
#
# Adds a 'release-branch/v<SEMVER>' target to create a release branch for a specific version.
# Running 'make release' inside the release branch will release the given SEMVER value.
#
# ------------------------------------------------------------------------------

RELEASE_LEVELS += \
	$(VERSION_LEVELS)

RELEASE_TARGETS += \
	$(patsubst %,release/%,$(RELEASE_LEVELS)) \

RELEASE_SEMANTIC_LEVELS += \
	bugfix \
	feature \
	breaking \

RELEASE_SEMANTIC_TARGETS += \
	$(patsubst %,release/%,$(RELEASE_SEMANTIC_LEVELS)) \

# <1.0.0
PREPUBLIC_bugfix := patch
PREPUBLIC_feature := patch
PREPUBLIC_breaking := minor

# >=1.0.0
PUBLIC_bugfix := patch
PUBLIC_feature := minor
PUBLIC_breaking := major

# ------------------------------------------------------------------------------

.PHONY: release
release: ## Release a new bugfix version.
	if [[ "$(GIT_BRANCH)" =~ ^release-v ]]; then \
		GIT_BRANCH_RELEASE=$(GIT_BRANCH); \
		$(ECHO_INFO) "Inside a release branch."; \
		$(MAKE) release/$$($(ECHO) "$(GIT_BRANCH)" | $(SED) "s/^release-//"); \
		$(ECHO) "[Q   ] Merging $${GIT_BRANCH_RELEASE} into master unless you specify another branch?"; \
		read GIT_BRANCH && \
			$(GIT) checkout $${GIT_BRANCH:-master}; \
		$(GIT) merge --no-ff refs/heads/$${GIT_BRANCH_RELEASE} || { \
			$(ECHO_ERR) "Automatic merge of the $${GIT_BRANCH_RELEASE} release branch was not possible."; \
			$(ECHO_INFO) "Please solve the merge conflicts e.g. by running 'git mergetool',"; \
			$(ECHO_INFO) "and push manually e.g. by running 'git push'."; \
			exit 1; \
		}; \
		$(GIT) push --no-verify; \
	else \
		$(MAKE) release/bugfix; \
	fi


.PHONY: release/public
release/public: ## Release the first public version 1.0.0.
ifeq (true,$(PKG_VSN_PUBLIC))
	$(ECHO_ERR) "Current version $(PKG_VSN) is beyond first public version (>=1.0.0)."
	exit 1
endif
	$(MAKE) release/major


.PHONY: $(RELEASE_TARGETS)
# NOTE: below is a workaround for 'make help-all' to work
release/patch:
release/minor:
release/major:
$(RELEASE_TARGETS):
	$(eval VSN_LEVEL := $(@:release/%=%))
	$(eval PKG_VSN_NEW := $(shell $(SEMVER) --coerce --increment $(VSN_LEVEL) $(PKG_VSN)))
	if [[ "$(GIT_BRANCH)" =~ ^release-v ]]; then \
		$(ECHO_ERR) "Cannot release $(PKG_VSN_NEW) from the $(GIT_BRANCH) release branch."; \
		exit 1; \
	else \
		$(ECHO_DO) "Releasing $(PKG_VSN_NEW)..."; \
		PKG_VSN_NEW=$(PKG_VSN_NEW) $(MAKE) _release; \
		$(ECHO_INFO) "Released $(PKG_VSN_NEW)."; \
		$(ECHO_DONE); \
	fi


.PHONY: release/v%
release/v%: ## Release a new specific version.
	$(eval PKG_VSN_NEW := $(@:release/v%=%))
	PKG_VSN_NEW=$(PKG_VSN_NEW) $(MAKE) _release


.PHONY: release-branch/v%
release-branch/v%: ## Create a release branch for a new specific version.
	$(eval PKG_VSN_NEW := $(@:release-branch/v%=%))
	$(eval GIT_BRANCH_RELEASE := release-v$(PKG_VSN_NEW))
	$(NPM) --no-git-tag-version version $(PKG_VSN_NEW)
	$(GIT) add package.json
	$(GIT) commit -m "Placeholder for $(GIT_BRANCH_RELEASE) release branch."
	$(GIT) push --no-verify
	$(ECHO_DO) "Creating the $(GIT_BRANCH_RELEASE) release branch..."
	$(GIT) checkout -b $(GIT_BRANCH_RELEASE) HEAD~
	$(GIT) push -u --no-verify
	$(ECHO_DONE)
	$(ECHO_INFO) "When ready to release, run 'make release' inside the release branch."


.PHONY: $(RELEASE_SEMANTIC_TARGETS)
# NOTE: below is a workaround for 'make help' to work
release/bugfix: ## Release a new semantic version with bugfix level.
release/feature: ## Release a new semantic version with feature level.
release/breaking: ## Release a new semantic version with breaking level.
$(RELEASE_SEMANTIC_TARGETS): release/%:
	$(eval RELEASE_SEMANTIC_LEVEL := $*)
ifeq (true,$(PKG_VSN_PUBLIC))
	$(eval RELEASE_LEVEL := $(PUBLIC_$(RELEASE_SEMANTIC_LEVEL)))
	$(eval PKG_VSN_NEW := $(shell $(SEMVER) --coerce --increment $(RELEASE_LEVEL) $(PKG_VSN)))
else
	$(eval RELEASE_LEVEL := $(PREPUBLIC_$(RELEASE_SEMANTIC_LEVEL)))
	$(eval PKG_VSN_NEW := $(shell $(SEMVER) --coerce --increment $(RELEASE_LEVEL) $(PKG_VSN)))
endif
	$(ECHO_DO) "Preparing to release $(PKG_VSN_NEW)..."
ifneq (true,$(PKG_VSN_PUBLIC))
	$(ECHO_INFO) "Current version $(PKG_VSN) is pre-public (<1.0.0)."
endif
	$(ECHO)
	$(MAKE) unreleased
	$(ECHO)
	$(ECHO) "       New $(RELEASE_SEMANTIC_LEVEL) release means new $(RELEASE_LEVEL) release."
	$(ECHO) "[Q   ] $(PKG_VSN) => $(PKG_VSN_NEW). Correct?"
	$(ECHO) "       Press ENTER to Continue."
	$(ECHO) "       Press Ctrl+C to Cancel."
	read -p ""
	$(MAKE) release/$(RELEASE_LEVEL)


.PHONY: unreleased
unreleased: unreleased/v$(PKG_VSN) ## Show unreleased commits.


.PHONY: unreleased/%
unreleased/%:
	$(ECHO_INFO) "Changes since $(*):"
	$(ECHO)
	$(GIT) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(*).. | \
		$(GREP) --color -i -E "^|break" || true
	$(ECHO)
	$(ECHO_INFO) "Breaking changes since $(*):"
	$(ECHO)
	$(GIT) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(*).. | \
		$(GREP) --color -i -E "break" || true
