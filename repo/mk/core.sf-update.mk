# Adds a 'support-firecloud/update' target which will update the support-firecloud git submodule,
# while also showing the git commits that the update will introduce.
#
# Commits that have the word 'break' will be colour highlighted,
# so the developer can take corrective actions when needed.
#
# ------------------------------------------------------------------------------

.PHONY: support-firecloud/update
support-firecloud/update: ## Update support-firecloud to latest master commit.
	$(eval SF_SUBMODULE_PATH := $(shell $(GIT) config --file .gitmodules --get-regexp path | \
		$(GREP) $(shell basename $(SUPPORT_FIRECLOUD_DIR)) | $(CUT) -d' ' -f2))
	$(eval SF_COMMIT := $(shell $(GIT) rev-parse HEAD^{commit}:$(SF_SUBMODULE_PATH)))
	$(ECHO_DO) "Updating $(SF_SUBMODULE_PATH)..."
	$(GIT) submodule update --init --recursive --remote $(SF_SUBMODULE_PATH)
	$(GIT) add $(SF_SUBMODULE_PATH)
	$(GIT) commit -m "updated $(SF_SUBMODULE_PATH)"
	$(GIT) submodule update --init --recursive $(SF_SUBMODULE_PATH)
	$(ECHO)
	$(ECHO_INFO) "Changes in $(SF_SUBMODULE_PATH) since $(SF_COMMIT):"
	$(ECHO)
	$(GIT) -C $(SF_SUBMODULE_PATH) --no-pager log \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(SF_COMMIT).. | \
		$(GREP) --color -E "^|break"
	$(ECHO)
	$(GIT) -C $(SF_SUBMODULE_PATH) --no-pager \
		diff --stat $(SF_COMMIT)..
	$(ECHO)
	$(ECHO_DONE)
