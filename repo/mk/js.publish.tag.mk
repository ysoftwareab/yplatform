# ------------------------------------------------------------------------------

publish:
	@$(ECHO_DO) "Publishing version..."
	$(GIT) push $(GIT_REMOTE) v`$(CAT) "package.json" | $(JSON) "version"`
	@$(ECHO_DONE)


publish/%:
	@$(ECHO_DO) "Publishing tag $*..."
	$(GIT) push $(GIT_REMOTE) $*
	@$(ECHO_DONE)


.PHONY: release
release: release/patch ## Release a new version (patch level).


.PHONY: release/%
release/%: ## Release a new version with given level (major/minor/patch).
	@$(ECHO_DO) "Release new $* version..."
	$(MAKE) version/$* publish
	sleep 15 # allow CI to pick the new tag first
	$(GIT) push
	@$(ECHO_DONE)
