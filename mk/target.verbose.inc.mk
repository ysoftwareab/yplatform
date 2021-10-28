# useful internally as
# YP_DEPS_TARGETS := $(subst deps-npm,verbose/deps-npm,$(YP_DEPS_TARGETS))

.PHONY: verbose/%
verbose/%: ## Run a target with verbosity on (VERBOSE=1 or V=1).
	@$(MAKE) V=1 $*
