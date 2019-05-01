# install a pre-push git hook that runs 'make check' on 'git push', before pushing to remote

# the hook can be ignored one time by running 'git push --no-verify'

# the hook can be not-installed by adding to the Makefile:
# SF_DEPS_TARGETS := $(filter-out .git/hooks/pre-push,$(SF_DEPS_TARGETS))

ifneq ($(wildcard .git),)
SF_DEPS_TARGETS := \
	$(SF_DEPS_TARGETS) \
	.git/hooks/pre-push \

endif

# ------------------------------------------------------------------------------

.git/hooks/pre-push:
	$(MKDIR) $(shell dirname $@)
	$(CP) $(SUPPORT_FIRECLOUD_DIR)/repo/dot.git/hooks/pre-push $@
