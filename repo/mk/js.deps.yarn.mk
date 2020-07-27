# Adds 'deps-yarn' and 'deps-yarn-prod' internal targets to install all and respectively prod-only npm dependencies.
# The 'deps-yarn' target is automatically included in the 'deps' target via SF_DEPS_TARGETS.
#
# ------------------------------------------------------------------------------

YARN = $(call which,YARN,yarn)
$(foreach VAR,YARN,$(call make-lazy,$(VAR)))

# see https://github.com/yarnpkg/yarn/issues/5869
YARN_CI_OR_INSTALL := install \
	--non-interactive \
	--skip-integrity-check \

ifeq (true,$(CI))
YARN_CI_OR_INSTALL := install \
	--check-files \
	--frozen-lockfile \
	--no-progress \
	--non-interactive \
	--skip-integrity-check \

endif

SF_CLEAN_FILES += \
	node_modules \

SF_DEPS_TARGETS += \
	deps-yarn \

ifdef SF_ECLINT_FILES_IGNORE
SF_ECLINT_FILES_IGNORE += \
	-e "^yarn.lock$$" \

endif

# ------------------------------------------------------------------------------

.PHONY: deps-yarn
deps-yarn:
#	'yarn install' will also remove extraneous dependencies
#	See https://classic.yarnpkg.com/en/docs/cli/prune/
	$(YARN) $(YARN_CI_OR_INSTALL)


.PHONY: deps-yarn-prod
deps-yarn-prod:
#	'yarn install' will also remove extraneous dependencies
#	See https://classic.yarnpkg.com/en/docs/cli/prune/
	$(YARN)  $(YARN_CI_OR_INSTALL) --production
