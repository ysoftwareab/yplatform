NPM_PUBLISH_GIT = $(call which,NPM_PUBLISH_GIT,npm-publish-git)
$(foreach VAR,NPM_PUBLISH_GIT,$(call make-lazy,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: publish
publish: ## Publish as a git version tag.
	@$(ECHO_DO) "Publishing version..."
	$(NPM_PUBLISH_GIT)
	@$(ECHO_DONE)


.PHONY: $(RELEASE_TARGETS)
# NOTE: below is a workaround for `make help` to work
release/patch: ## Release a new patch-bumped version.
release/minor: ## Release a new minor-bumped version.
release/major: ## Release a new major-bumped version.
$(RELEASE_TARGETS):
	$(eval VSN := $(@:release/%=%))
	VSN=$(VSN) $(MAKE) _release


.PHONY: release/v%
release/v%: ## Release a new specific version.
	$(eval VSN := $(@:release/v%=%))
	VSN=$(VSN) $(MAKE) _release


.PHONY: _release
_release:
	@$(ECHO_DO) "Release new $(VSN) version..."
	$(MAKE) nuke all test version/v$(VSN) publish
	sleep 15 # allow CI to pick the new tag first
	$(GIT) fetch
#	if upstream diverged, create merge commit or else `git push` fails
	[[ `$(GIT) rev-list --count HEAD..@{u}` = 0 ]] || { \
		$(ECHO_INFO) "Upstream has new commits..."; \
		$(GIT) --no-pager log \
			--graph \
			--date=short \
			--pretty=format:"%h %ad %s" \
			--no-decorate \
			`$(GIT) rev-parse HEAD`..`$(GIT) rev-parse @{u}`; \
		GIT_TAG=`$(GIT) tag -l --points-at HEAD | $(HEAD) -1`; \
		$(ECHO_INFO) "Merging in tag $${GIT_TAG}..."; \
		$(GIT) reset @{u}; \
		$(GIT) merge --no-ff refs/tags/$${GIT_TAG} -m "Merge tag $${GIT_TAG}"; \
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
