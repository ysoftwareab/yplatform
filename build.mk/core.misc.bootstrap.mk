# Adds a 'boostrap' target that will bootstrap the system
# with dependencies that are specific to the repository.
#
# ------------------------------------------------------------------------------

.PHONY: bootstrap
bootstrap: ## Bootstrap your system.
	$(ECHO_DO) "Bootstrapping..."
	$(YP_DIR)/bootstrap/bootstrap
	$(ECHO_DONE)
