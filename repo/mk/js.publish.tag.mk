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
	$(GIT) fetch
#	if upstream diverged, create merge commit or else `git push` fails
	[[ `$(GIT) rev-parse HEAD~` = `$(GIT) rev-parse @{u}` ]] || { \
		$(ECHO_INFO) "Upstream has new commits..."; \
		$(GIT) log --oneline --no-color --no-decorate `$(GIT) rev-parse HEAD~`..`$(GIT) rev-parse @{u}`; \
		GIT_TAG=`$(GIT) tag -l --points-at -n1 HEAD`; \
		$(ECHO_INFO) "Merging in tag ${GIT_TAG} instead of fast-forwarding..."; \
		$(GIT) commit-tree -p @{u} -p HEAD \
			-m "Merge tag ${GIT_TAG}" "HEAD^{tree}" | read GIT_MERGE_COMMIT; \
		$(GIT) reset $${GIT_MERGE_COMMIT}; \
	}
	$(GIT) push
	@$(ECHO_DONE)
