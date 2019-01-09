RELEASE_SEMANTIC_LEVELS := \
	bugfix \
	feature \
	breaking \

RELEASE_SEMANTIC_TARGETS := $(patsubst %,release/%,$(RELEASE_SEMANTIC_LEVELS))

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
release: release/patch ## Release a new patch version.


.PHONY: release/public
release/public: ## Release the first public version 1.0.0.
ifeq (true,$(PKG_VSN_PUBLIC))
	$(ECHO_ERR) "Current version $(PKG_VSN) is beyond first public version (>=1.0.0)."
	exit 1
endif
	$(MAKE) release/major


.PHONY: $(RELEASE_SEMANTIC_TARGETS)
# NOTE: below is a workaround for `make help` to work
release/bugfix: ## Release a new semantic version with bugfix level.
release/feature: ## Release a new semantic version with feature level.
release/breaking: ## Release a new semantic version with breaking level.
$(RELEASE_SEMANTIC_TARGETS): release/%:
	$(eval RELEASE_SEMANTIC_LEVEL := $*)
ifeq (true,$(PKG_VSN_PUBLIC))
	$(eval RELEASE_LEVEL := $(PUBLIC_$(RELEASE_SEMANTIC_LEVEL)))
else
	$(eval RELEASE_LEVEL := $(PREPUBLIC_$(RELEASE_SEMANTIC_LEVEL)))
	$(ECHO_INFO) "Current version $(PKG_VSN) is pre-public (<1.0.0)."
endif
	$(eval PKG_VSN_NEW := $(shell $(NPX) semver --increment $(RELEASE_LEVEL) $(PKG_VSN)))
	$(ECHO)
	$(ECHO) "       New $(RELEASE_SEMANTIC_LEVEL) release means new $(RELEASE_LEVEL) release."
	$(ECHO) "[Q   ] $(PKG_VSN) => $(PKG_VSN_NEW). Correct?"
	$(ECHO) "       Wait 10 seconds or press ENTER to Continue."
	$(ECHO) "       Press Ctrl+C to Cancel."
	read -t 10 -p ""
	$(MAKE) release/$(RELEASE_LEVEL)
