publish:
	@$(ECHO_DO) "Publishing version..."
	$(GIT) push $(GIT_REMOTE) v`$(CAT) "package.json" | $(JSON) "version"`
	@$(ECHO_DONE)


publish/%:
	@$(ECHO_DO) "Publishing tag $*..."
	$(GIT) push $(GIT_REMOTE) $*
	@$(ECHO_DONE)
