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
release: release/bugfix ## Release a new bugfix version.


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
	$(eval VSN := $(@:release/%=%))
	$(eval PKG_VSN_NEW ?= $(shell $(NPX) semver --coerce --increment $(VSN) $(PKG_VSN)))
	$(ECHO_DO) "Releasing $(PKG_VSN_NEW)..."
	VSN=$(VSN) $(MAKE) _release
	$(ECHO_INFO) "Released $(PKG_VSN_NEW)."
	$(ECHO_DONE)


.PHONY: release/v%
release/v%: ## Release a new specific version.
	$(eval VSN := $(@:release/v%=%))
	VSN=$(VSN) $(MAKE) _release


.PHONY: $(RELEASE_SEMANTIC_TARGETS)
# NOTE: below is a workaround for 'make help' to work
release/bugfix: ## Release a new semantic version with bugfix level.
release/feature: ## Release a new semantic version with feature level.
release/breaking: ## Release a new semantic version with breaking level.
$(RELEASE_SEMANTIC_TARGETS): release/%:
	$(eval RELEASE_SEMANTIC_LEVEL := $*)
ifeq (true,$(PKG_VSN_PUBLIC))
	$(eval RELEASE_LEVEL := $(PUBLIC_$(RELEASE_SEMANTIC_LEVEL)))
else
	$(eval RELEASE_LEVEL := $(PREPUBLIC_$(RELEASE_SEMANTIC_LEVEL)))
endif
	$(eval PKG_VSN_NEW := $(shell $(NPX) semver --increment $(RELEASE_LEVEL) $(PKG_VSN)))
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
		$(GREP) --color -E "^|break" || true
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
		$(GREP) --color -E "break" || true
