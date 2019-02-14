# ------------------------------------------------------------------------------

publish:
	@$(ECHO_DO) "Publishing version..."
	$(GIT) push $(GIT_REMOTE) v`$(CAT) "package.json" | $(JSON) "version"`
	@$(ECHO_DONE)


.PHONY: $(RELEASE_TARGETS)
$(RELEASE_TARGETS): ## Release a new major/minor/patch-bumped version.
	$(eval VSN := $(@:release/%=%))
	VSN=$(VSN) $(MAKE) _release


.PHONY: release/v%
release/v%: ## Release a new specific version.
	$(eval VSN := $(@:release/v%=%))
	VSN=$(VSN) $(MAKE) _release


.PHONY: _release
_release:
	@$(ECHO_DO) "Release new $(VSN) version..."
	$(MAKE) version/v$(VSN) publish
	sleep 15 # allow CI to pick the new tag first
	$(GIT) fetch
#	if upstream diverged, create merge commit or else `git push` fails
	[[ `$(GIT) rev-list --count HEAD..@{u}` = 0 ]] || { \
		$(ECHO_INFO) "Upstream has new commits..."; \
		$(GIT) log --oneline --no-color --no-decorate `$(GIT) rev-parse HEAD`..`$(GIT) rev-parse @{u}`; \
		GIT_TAG=`$(GIT) tag -l --points-at HEAD | $(HEAD) -1`; \
		$(ECHO_INFO) "Merging in tag $${GIT_TAG} instead of fast-forwarding..."; \
		$(GIT) commit-tree -p @{u} -p HEAD \
			-m "Merge tag $${GIT_TAG}" "HEAD^{tree}" | read GIT_MERGE_COMMIT; \
		$(GIT) reset $${GIT_MERGE_COMMIT}; \
	}
	$(GIT) push
	@$(ECHO_DONE)
