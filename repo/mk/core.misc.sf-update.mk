# Adds a 'support-firecloud/update' target which will update the support-firecloud git submodule
# to the latest version (semver tag), while also showing the git commits that the update will introduce.
#
# Commits that have the word 'break' will be colour highlighted,
# so the developer can take corrective actions when needed.
#
# ------------------------------------------------------------------------------

.PHONY: _support-firecloud/update
_support-firecloud/update:
	$(eval SF_SUBMODULE_PATH := $(shell $(GIT) config --file .gitmodules --get-regexp path | \
		$(GREP) $(shell basename $(SUPPORT_FIRECLOUD_DIR)) | $(CUT) -d' ' -f2))
	[[ -n "$(SF_SUBMODULE_PATH)" ]] || { \
		$(ECHO_ERR) "Couldn't find 'support-firecloud' git submodule."; \
		exit 1; \
	}
	$(GIT) submodule update --init --recursive $(SF_SUBMODULE_PATH)
	$(eval SF_COMMIT := $(shell $(GIT) rev-parse HEAD^{commit}:$(SF_SUBMODULE_PATH)))


.PHONY: support-firecloud/update
support-firecloud/update: _support-firecloud/update ## Update support-firecloud to latest version.
	$(GIT) -C $(SF_SUBMODULE_PATH) fetch --force --tags
	$(eval SF_LATEST_VSN := $(shell $(GIT) -C $(SF_SUBMODULE_PATH) tag \
		--list \
		--sort=version:refname "v*" | \
		$(TAIL) -n1) | \
		$(SED) "s/^v//")
	$(MAKE) support-firecloud/update/$(SF_LATEST_VSN)


.PHONY: support-firecloud/update/v%
support-firecloud/update/v%: _support-firecloud/update ## Update support-firecloud to a specific version.
	$(eval SF_VSN := $(@:support-firecloud/update/v%=%))
	$(ECHO_DO) "Updating $(SF_SUBMODULE_PATH) to $(SF_VSN)..."
	$(GIT) -C $(SF_SUBMODULE_PATH) reset --hard refs/tags/v$(SF_VSN)
	$(GIT) add $(SF_SUBMODULE_PATH)
	$(GIT) commit -m "updated $(SF_SUBMODULE_PATH) to $(SF_VSN)"
	$(GIT) submodule update --init --recursive $(SF_SUBMODULE_PATH)
	$(ECHO)
	$(ECHO_INFO) "Changes in $(SF_SUBMODULE_PATH) since $(SF_COMMIT):"
	$(ECHO)
	$(GIT) -C $(SF_SUBMODULE_PATH) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(SF_COMMIT).. | \
		$(GREP) --color -E "^|break" || true
	$(ECHO)
	$(ECHO_INFO) "Breaking changes in $(SF_SUBMODULE_PATH) since $(SF_COMMIT):"
	$(ECHO)
	$(GIT) -C $(SF_SUBMODULE_PATH) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(SF_COMMIT).. | \
		$(GREP) --color -E "break" || true
	$(ECHO)
	$(GIT) -C $(SF_SUBMODULE_PATH) --no-pager \
		diff --stat $(SF_COMMIT)..
	$(ECHO)
	$(ECHO_DONE)
