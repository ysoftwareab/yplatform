.PHONY: publish
publish: ## Publish as a git version tag.
	@$(ECHO_DO) "Publishing version..."
	$(NPM_PUBLISH_GIT)
	@$(ECHO_DONE)


.PHONY: publish/%
publish/%: ## Publish as given git tag.
	@$(ECHO_DO) "Publishing tag ${*}..."
	$(NPM_PUBLISH_GIT) --tag ${*}
	@$(ECHO_DONE)


.PHONY: package-json-prepare
ifneq (node_modules,$(shell basename $(abspath ..))) # let Makefile build, or else build runs twice
package-json-prepare:
	:
else # installing as dependency
package-json-prepare: build
endif
