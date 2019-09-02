# ------------------------------------------------------------------------------

.PHONY: bootstrap
bootstrap: ## Bootstrap your system skipping 'dev'. Run 'make bootstrap/scratch' to include 'dev'.
	$(ECHO_DO) "Bootstrapping (skip dev)..."
	SF_BOOTSTRAP_SKIP_COMMON=true $(SUPPORT_FIRECLOUD_DIR)/ci/repo/bootstrap
	$(ECHO_DONE)


.PHONY: bootstrap/scratch
bootstrap/scratch:
	$(ECHO_DO) "Bootstrapping..."
	$(SUPPORT_FIRECLOUD_DIR)/ci/$(OS_SHORT)/bootstrap
	$(ECHO_DONE)
