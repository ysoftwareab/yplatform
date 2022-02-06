# This is a collection of internal targets implementing
# releasing new versions as npm packages reachable via git tags.
#
# ------------------------------------------------------------------------------

NPM_PUBLISH_GIT = $(call npm-which,NPM_PUBLISH_GIT,npm-publish-git)
$(foreach VAR,NPM_PUBLISH_GIT,$(call make-lazy-once,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: _publish
_publish:
	@$(ECHO_DO) "Publishing version..."
	$(NPM_PUBLISH_GIT)
	@$(ECHO_DONE)


.PHONY: _release
_release:
	@$(ECHO_DO) "Release new $(PKG_VSN_NEW) version..."
	$(MAKE) nuke all test version/v$(PKG_VSN_NEW) _publish
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
		GIT_TAG=$$($(GIT) tag --points-at HEAD | $(HEAD) -1); \
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


.PHONY: package-json-prepare
# if INIT_CWD contains ".npm/_cacache/tmp/git-clone-", then we are a dependency
# otherwise, we are standalone
package-json-prepare:
	if [[ "$${INIT_CWD:-}" == *".npm/_cacache/tmp/git-clone-"* ]]; then \
		$(ECHO_INFO) "package-json-prepare: Dependency mode. Calling build."; \
		$(MAKE) build; \
	else \
		$(ECHO_INFO) "package-json-prepare: Standalone mode. Skip build."; \
	fi
