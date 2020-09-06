# Adds a '.git/hooks/pre-push' internal target that will generate a pre-push git hook.
# The '.git/hooks/pre-push' is automatically added to the 'deps' target via SF_DEPS_TARGETS.
#
# The pre-push git hook is intended to run 'make check' on 'git push', before pushing to remote that is.
#
# The pre-push git hook can be ignored by running 'git push --no-verify'.
#
# For specific repositories where 'make check' is slow,
# the hook's automatic addition to the 'deps' target
# can be skipped via:
# SF_DEPS_TARGETS := $(filter-out .git/hooks/pre-push,$(SF_DEPS_TARGETS))
#
# ------------------------------------------------------------------------------
#
# Adds a '.git/hooks/pre-push/run' internal target that will be the actual code of the hook.
# By default, it runs 'make check'.
#
# To add another pre-push target do
# SF_GIT_HOOKS_PRE_PUSH_TARGETS += \
#	do-something-else \
#
# ------------------------------------------------------------------------------

ifneq (,$(wildcard .git))
SF_DEPS_TARGETS += \
	.git/hooks/pre-push \

endif

SF_GIT_HOOKS_PRE_PUSH_TARGETS += \
	check \

# ------------------------------------------------------------------------------

.git/hooks/pre-push: $(SUPPORT_FIRECLOUD_DIR)/repo/dot.git/hooks/pre-push
	$(MKDIR) $$(dirname $@)
	$(CP) $< $@


.PHONY: .git/hooks/pre-push/run
.git/hooks/pre-push/run:
	[[ "$(words $(SF_GIT_HOOKS_PRE_PUSH_TARGETS))" = "0" ]] || { \
		$(MAKE) $(SF_GIT_HOOKS_PRE_PUSH_TARGETS); \
	}
