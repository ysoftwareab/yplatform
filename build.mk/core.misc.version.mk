# Adds 'version/patch', 'version/minor' and 'version/major' internal targets
# to bump the version accordingly.
#
# ------------------------------------------------------------------------------
#
# Adds a 'version/v<SEMVER>' internal target to set the version to the given SEMVER value.
#
# ------------------------------------------------------------------------------
#
# All 'version/*' internal targets will generate release notes in the 'release-notes' folder.
# If interactive (most common), it will open up the editor for manual changes,
# specifically adding highlights.
# Upon exiting the editor, if the notes are empty, the version bump is aborted.
#
# ------------------------------------------------------------------------------

YP_VENDOR_FILES_IGNORE += \
	-e "^release\-notes/" \

VERSION_LEVELS := \
	patch \
	minor \
	major \

VERSION_TARGETS += \
	$(patsubst %,version/%,$(VERSION_LEVELS)) \

# SEMVER = $(call npm-which,SEMVER,semver)
# $(foreach VAR,SEMVER,$(call make-lazy-once,$(VAR)))
# NOTE using npx in case semver is not global as per bootstrap/brew-install-node.inc.sh
SEMVER ?= $(NPX) -y semver@7

PKG_VSN_MAJOR = $(shell $(ECHO) "$(PKG_VSN)" | $(CUT) -d"." -f1)
PKG_VSN_PUBLIC =
ifneq (0,$(PKG_VSN_MAJOR))
PKG_VSN_PUBLIC = true
endif
$(foreach VAR,PKG_VSN PKG_VSN_MAJOR PKG_VSN_PUBLIC,$(call make-lazy-once,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: $(VERSION_TARGETS)
# NOTE: below is a workaround for 'make help-all' to work
version/patch:
version/minor:
version/major:
$(VERSION_TARGETS):
	$(eval VSN_LEVEL := $(@:version/%=%))
	$(eval PKG_VSN_NEW := $(shell $(SEMVER) --coerce --increment $(VSN_LEVEL) $(PKG_VSN)))
	PKG_VSN_NEW=$(PKG_VSN_NEW) $(MAKE) _version


.PHONY: version/v%
version/v%:
	$(eval PKG_VSN_NEW := $(@:version/v%=%))
	PKG_VSN_NEW=$(PKG_VSN_NEW) $(MAKE) _version


.PHONY: release-notes
release-notes: release-notes/HEAD


# NOTE not using v% in order to allow for any commitish i.e. HEAD
.PHONY: release-notes/%
release-notes/%:
	$(eval RANGE_TO := $(@:release-notes/%=%))
	$(eval VSN_TAG ?= ${RANGE_TO})
	@$(ECHO_DO) "Generating release notes for $(VSN_TAG)..."
	$(MKDIR) release-notes
	if [[ "$(RANGE_TO)" =~ ^v ]] || [[ "$(VSN_TAG)" != "HEAD" ]]; then \
		$(GIT) diff --exit-code -- release-notes/$(VSN_TAG).txt 2>/dev/null || { \
			$(ECHO_ERR) "release-notes/$(VSN_TAG).txt has changed. Please commit your changes."; \
			exit 1; \
		}; \
		$(YP_DIR)/bin/release-notes \
			--pkg-name $(PKG_NAME) \
			--pkg-vsn $(VSN_TAG) \
			--to $(RANGE_TO) \
			> release-notes/$(VSN_TAG).txt; \
		if [[ -t 0 ]] && [[ -t 1 ]]; then \
			$(EDITOR) release-notes/$(VSN_TAG).txt; \
			[[ -s release-notes/$(VSN_TAG).txt ]] || { \
				$(ECHO_ERR) "Aborting due to empty release-notes/$(VSN_TAG).txt."; \
				$(RM) release-notes/$(VSN_TAG).txt; \
				exit 1; \
			}; \
		else \
			$(ECHO_INFO) "No tty."; \
			$(ECHO_SKIP) "$(EDITOR) release-notes/$(VSN_TAG).txt"; \
		fi; \
		$(CAT) release-notes/$(VSN_TAG).txt; \
	else \
		$(YP_DIR)/bin/release-notes \
			--pkg-name $(PKG_NAME) \
			--pkg-vsn $(VSN_TAG) \
			--to $(RANGE_TO); \
	fi
	@$(ECHO_DONE)


.PHONY: _version
_version:
	$(eval VSN_TAG := v$(PKG_VSN_NEW))
	$(GIT) diff --exit-code || { \
		$(ECHO_ERR) "The working directory is dirty."; \
		$(ECHO_INFO) "Please commit your changes before bumping the version." \
		exit 1; \
	}
	@$(ECHO_DO) "Bumping $(PKG_VSN_NEW) version..."
	VSN_TAG=$(VSN_TAG) $(MAKE) release-notes/HEAD
	$(GIT) add release-notes/$(VSN_TAG).txt
	$(GIT) commit -m "$(PKG_VSN_NEW) release notes"
	$(NPM) version $(PKG_VSN_NEW)
	$(GIT) tag $(VSN_TAG) $(VSN_TAG)^{} -f -F release-notes/$(VSN_TAG).txt
	@$(ECHO_DONE)
