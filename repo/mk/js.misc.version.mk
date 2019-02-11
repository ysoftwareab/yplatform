VERSION_LEVELS := \
	patch \
	minor \
	major \

VERSION_TARGETS := $(patsubst %,version/%,$(VERSION_LEVELS))

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


.PHONY: $(VERSION_TARGETS)
$(VERSION_TARGETS): version/% ## Bump major/minor/patch version.
	$(eval VSN := $(@:version/%=%))
	VSN=$(VSN) $(MAKE) _version


.PHONY: version/v%
version/v%: ## Bump to specific version.
	$(eval VSN := $(@:version/v%=%))
	VSN=$(VSN) $(MAKE) _version


.PHONY: _version
_version:
	@$(ECHO_DO) "Bumping $(VSN) version..."
	$(NPM) version $(VSN)
	@$(ECHO_DONE)
