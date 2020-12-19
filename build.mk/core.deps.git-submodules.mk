# Adds an internal 'deps-git-submodules' target that will sync git submodules.
#
# ------------------------------------------------------------------------------

SF_DEPS_TARGETS += \
	deps-git-submodules \

# ------------------------------------------------------------------------------

.PHONY: deps-git-submodules
deps-git-submodules:
	$(ECHO_DO) "Syncing git submodules..."
	$(GIT) submodule sync --recursive
	$(GIT) submodule update --init --recursive
	$(ECHO_DONE)
