NPM_PUBLISH_GIT = $(call which,NPM_PUBLISH_GIT,npm-publish-git)

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
