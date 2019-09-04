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

ifneq (,$(wildcard .git))
SF_DEPS_TARGETS := \
	$(SF_DEPS_TARGETS) \
	.git/hooks/pre-push \

endif

# ------------------------------------------------------------------------------

.git/hooks/pre-push: $(SUPPORT_FIRECLOUD_DIR)/repo/dot.git/hooks/pre-push
	$(MKDIR) $(shell dirname $@)
	$(CP) $< $@
