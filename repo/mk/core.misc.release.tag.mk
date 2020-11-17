# This is a collection of internal targets implementing
# releasing new versions as git tags.
#
# ------------------------------------------------------------------------------

.PHONY: _publish
_publish: guard-env-GIT_REMOTE
	@$(ECHO_DO) "Publishing version..."
	$(GIT) push --no-verify $(GIT_REMOTE) v$$($(CAT) "package.json" | $(JQ) -r ".version")
	@$(ECHO_DONE)


.PHONY: _release
_release:
	@$(ECHO_DO) "Release new $(PKG_VSN_NEW) version..."
	# $(MAKE) nuke all test version/v$(PKG_VSN_NEW) _publish
	# no need for 'nuke all test'
	$(MAKE) deps check version/v$(PKG_VSN_NEW) _publish
	$(SLEEP) 15 # allow CI to pick the new tag first
	$(GIT) fetch
#	if upstream diverged, create merge commit or else 'git push' fails
	[[ $$($(GIT) rev-list --count HEAD..@{u}) = 0 ]] || { \
		$(ECHO_INFO) "Upstream has new commits..."; \
		$(GIT) --no-pager log \
			--color \
			--graph \
			--date=short \
			--pretty=format:"%h %ad %s" \
			--no-decorate \
			$$($(GIT) rev-parse HEAD)..$$($(GIT) rev-parse @{u}); \
		GIT_TAG=$$($(GIT) tag -l --points-at HEAD | $(HEAD) -1); \
		$(ECHO_INFO) "Merging in tag $${GIT_TAG}..."; \
		$(GIT) reset --hard @{u}; \
		$(GIT) merge --no-ff refs/tags/$${GIT_TAG} -m "Merge tag '$${GIT_TAG}'" || { \
			$(ECHO_ERR) "Automatic merge of the $${GIT_TAG} release tag was not possible."; \
			$(ECHO_INFO) "Please solve the merge conflicts e.g. by running 'git mergetool',"; \
			$(ECHO_INFO) "and push manually e.g. by running 'git push'."; \
			exit 1; \
		}; \
	}
	$(GIT) push --no-verify
	@$(ECHO_DONE)
