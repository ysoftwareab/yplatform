publish:
	@$(ECHO_DO) "Publishing version..."
	$(GIT) push origin v`$(CAT) "package.json" | $(JSON) "version"`
	@$(ECHO_DONE)


publish/%:
	@$(ECHO_DO) "Publishing tag ${*}..."
	$(GIT) push origin ${*}
	@$(ECHO_DONE)
