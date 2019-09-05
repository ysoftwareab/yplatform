# Adds a 'boostrap' target that will bootstrap the system
# with dependencies that are specific to the repository.
#
# ------------------------------------------------------------------------------
#
# Adds a 'bootstrap/scratch' target that will bootstrap the system
# first with common dependencies (same as running the ~/git/firecloud/support-firecloud/dev/boostrap script)
# and then with dependencies that are specific to the repository.
#
# ------------------------------------------------------------------------------

.PHONY: bootstrap
bootstrap: ## Bootstrap your system, skipping 'dev'.
	$(ECHO_DO) "Bootstrapping (skip dev)..."
	$(SUPPORT_FIRECLOUD_DIR)/ci/repo/bootstrap
	$(ECHO_DONE)


.PHONY: bootstrap/scratch
bootstrap/scratch: ## Bootstrap your system from scratch, including 'dev'.
	$(ECHO_DO) "Bootstrapping..."
	$(SUPPORT_FIRECLOUD_DIR)/ci/$(OS_SHORT)/bootstrap
	$(ECHO_DONE)
