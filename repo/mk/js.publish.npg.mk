NPM_PUBLISH_GIT = $(call which,NPM_PUBLISH_GIT,npm-publish-git)
$(foreach VAR,NPM_PUBLISH_GIT,$(call make-lazy,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: publish
publish: ## Publish as a git version tag.
	@$(ECHO_DO) "Publishing version..."
	$(NPM_PUBLISH_GIT)
	@$(ECHO_DONE)


.PHONY: publish/%
publish/%: ## Publish as given git tag.
	@$(ECHO_DO) "Publishing tag $*..."
	$(NPM_PUBLISH_GIT) --tag $*
	@$(ECHO_DONE)


.PHONY: release
release: release/patch ## Release a new version (patch level).


.PHONY: release/%
release/%: ## Release a new version with given level (major/minor/patch).
	@$(ECHO_DO) "Release new $* version..."
	$(MAKE) nuke all test version/$* publish
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
