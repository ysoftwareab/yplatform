PKG_VSN = $(shell $(CAT) package.json | $(JQ) ".version")
PKG_VSN_MAJOR = $(shell $(ECHO) "$(PKG_VSN)" | $(CUT) -d"." -f1)
PKG_VSN_PUBLIC =
ifneq (0,$(PKG_VSN_MAJOR))
PKG_VSN_PUBLIC = true
endif
$(foreach VAR,PKG_VSN PKG_VSN_MAJOR PKG_VSN_PUBLIC,$(call make-lazy,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: version
version: version/patch ## Bump patch version.


.PHONY: version/%
version/%: ## Bump major/minor/patch version.
	@$(ECHO_DO) "Bumping $* version..."
	$(NPM) version $*
	@$(ECHO_DONE)
