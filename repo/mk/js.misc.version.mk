.PHONY: version
version: version/patch ## Bump version (patch level).


.PHONY: version/%
version/%: ## Bump version to given level (major/minor/patch).
	@$(ECHO_DO) "Bumping $* version..."
	$(NPM) version $*
	@$(ECHO_DONE)
