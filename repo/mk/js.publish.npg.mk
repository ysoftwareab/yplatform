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
	$(GIT) push
	@$(ECHO_DONE)


.PHONY: package-json-prepare
ifneq (node_modules,$(shell basename $(abspath ..))) # let Makefile build, or else build runs twice
package-json-prepare:
	:
else # installing as dependency
package-json-prepare: build
endif
