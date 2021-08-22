# useful internally as
# SF_DEPS_TARGETS := $(subst deps-npm,verbose/deps-npm,$(SF_DEPS_TARGETS))

.PHONY: verbose/%
verbose/%: ## Run a target with verbosity on (VERBOSE=1 or V=1).
	@$(MAKE) V=1 $*
