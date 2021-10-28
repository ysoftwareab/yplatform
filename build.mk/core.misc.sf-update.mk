# Adds a 'yplatform/update' target which will update the yplatform git submodule
# to the latest version (semver tag), while also showing the git commits that the update will introduce.
#
# Commits that have the word 'break' will be colour highlighted,
# so the developer can take corrective actions when needed.
#
# ------------------------------------------------------------------------------

.PHONY: _yplatform/update
_yplatform/update:
	$(eval SF_SUBMODULE_PATH := $(shell $(GIT) config --file .gitmodules --get-regexp path | \
		$(GREP) $(shell basename $(SUPPORT_FIRECLOUD_DIR)) | $(CUT) -d' ' -f2))
	[[ -n "$(SF_SUBMODULE_PATH)" ]] || { \
		$(ECHO_ERR) "Couldn't find 'yplatform' git submodule."; \
		exit 1; \
	}
	$(GIT) submodule update --init --recursive $(SF_SUBMODULE_PATH)
	$(GIT) -C $(SF_SUBMODULE_PATH) fetch --force --tags


.PHONY: yplatform/update
yplatform/update: _yplatform/update ## Update 'yplatform' to latest version.
	$(MAKE) yplatform/update/$$($(GIT) -C $(SF_SUBMODULE_PATH) tag \
		--list \
		--sort=version:refname "v*" | \
		$(TAIL) -n1)


.PHONY: yplatform/update/v%
yplatform/update/v%: _yplatform/update ## Update 'yplatform' to a specific version.
	$(eval SF_UPDATE_VSN := $(@:yplatform/update/v%=%))
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
	read -r -p "" -n1
	$(GIT) -C $(SF_SUBMODULE_PATH) reset --hard $(SF_UPDATE_COMMIT)
	$(GIT) add $(SF_SUBMODULE_PATH)
	$(GIT) commit -m "updated $(SF_SUBMODULE_PATH) to v$(SF_UPDATE_VSN)"
	$(GIT) submodule update --init --recursive $(SF_SUBMODULE_PATH)
	$(ECHO_DONE)
	$(MAKE) deps
