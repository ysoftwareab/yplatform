# ------------------------------------------------------------------------------

.PHONY: teardown-env
teardown-env: ## Teardown env
	! $(GIT_REPO_HAS_STAGED_FILES) || { \
		$(ECHO_ERR) "Unstage your changes before calling 'make teardown-env'."; \
		$(GIT) status --porcelain | $(GREP) -e "^[^ U]"; \
		exit 1; \
	}
	$(GIT) commit --allow-empty -m "[sf teardown-$(ENV_NAME)]"
	$(GIT) push -f
