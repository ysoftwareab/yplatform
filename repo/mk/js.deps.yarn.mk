# Adds 'deps-yarn' and 'deps-yarn-prod' internal targets to install all and respectively prod-only npm dependencies.
# The 'deps-yarn' target is automatically included in the 'deps' target via SF_DEPS_TARGETS.
#
# ------------------------------------------------------------------------------

YARN = $(call which,YARN,yarn)
$(foreach VAR,YARN,$(call make-lazy,$(VAR)))

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
#	'yarn install' witll also remove extraneous dependencies
#	See https://classic.yarnpkg.com/en/docs/cli/prune/
	$(YARN) install \
		--check-files \
		--frozen-lockfile \
		--non-interactive

.PHONY: deps-yarn-prod
deps-yarn-prod:
#	'yarn install' witll also remove extraneous dependencies
#	See https://classic.yarnpkg.com/en/docs/cli/prune/
	$(YARN) install \
		--check-files \
		--frozen-lockfile \
		--non-interactive \
		--production
