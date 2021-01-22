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
	$(GIT) -C $(SF_SUBMODULE_PATH) fetch --force --tags


.PHONY: support-firecloud/update
support-firecloud/update: _support-firecloud/update ## Update 'support-firecloud' to latest version.
	$(MAKE) support-firecloud/update/$$($(GIT) -C $(SF_SUBMODULE_PATH) tag \
		--list \
		--sort=version:refname "v*" | \
		$(TAIL) -n1)


.PHONY: support-firecloud/update/v%
support-firecloud/update/v%: _support-firecloud/update ## Update 'support-firecloud' to a specific version.
	$(eval SF_UPDATE_VSN := $(@:support-firecloud/update/v%=%))
	$(eval SF_UPDATE_COMMIT := refs/tags/v$(SF_UPDATE_VSN))
	$(eval SF_UPDATE_COMMIT_RANGE := $(SF_COMMIT)..$(SF_UPDATE_COMMIT))
	$(ECHO_DO) "Updating $(SF_SUBMODULE_PATH) to v$(SF_UPDATE_VSN)..."
	$(ECHO)
	$(ECHO_INFO) "Changes in $(SF_SUBMODULE_PATH)@$(SF_UPDATE_VSN) since $(SF_VSN) $(SF_COMMIT):"
	$(ECHO)
	$(GIT) -C $(SF_SUBMODULE_PATH) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(SF_UPDATE_COMMIT_RANGE) | \
		$(GREP) --color -i -E "^|break" || true
	$(ECHO)
	$(ECHO_INFO) "Breaking changes in $(SF_SUBMODULE_PATH)@$(SF_UPDATE_VSN) since $(SF_VSN) $(SF_COMMIT):"
	$(ECHO)
	$(GIT) -C $(SF_SUBMODULE_PATH) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(SF_UPDATE_COMMIT_RANGE) | \
		$(GREP) --color -i -E "break" || true
	$(ECHO)
	$(GIT) -C $(SF_SUBMODULE_PATH) --no-pager \
		diff --stat $(SF_UPDATE_COMMIT_RANGE)
	$(ECHO)
	$(ECHO) "[Q   ] Updating $(SF_SUBMODULE_PATH) to v$(SF_UPDATE_VSN). OK?"
	$(ECHO) "       Press ENTER to Continue."
	$(ECHO) "       Press Ctrl+C to Cancel."
	read -p ""
	$(GIT) -C $(SF_SUBMODULE_PATH) reset --hard $(SF_UPDATE_COMMIT)
	$(GIT) add $(SF_SUBMODULE_PATH)
	$(GIT) commit -m "updated $(SF_SUBMODULE_PATH) to v$(SF_UPDATE_VSN)"
	$(GIT) submodule update --init --recursive $(SF_SUBMODULE_PATH)
	$(ECHO_DONE)
	$(MAKE) deps
