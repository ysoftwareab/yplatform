# Update the support-firecloud folder while keeping the index
# (and even making it look like it's not dirty at all ?! maybe not needed,
#   but otherwise everyone would ask why is support-firecloud always dirty).
# The submodule cannot have the index changed because then the `deps-git` target
# with always revert the index via `git submodule update`.

SF_DEPS_TARGETS := \
	$(SF_DEPS_TARGETS) \
	deps-latest-sf \

SUPPORT_FIRECLOUD_DIR_REL = $(shell python2 -c "import os.path; print os.path.relpath('$(SUPPORT_FIRECLOUD_DIR)', '$(GIT_ROOT)')")"

SUPPORT_FIRECLOUD_TRACKING_BRANCH = $(shell $(GIT) config -f $(GIT_ROOT)/.gitmodules submodule."$(SUPPORT_FIRECLOUD_DIR_REL)".branch)

# ------------------------------------------------------------------------------

.PHONY: deps-latest-sf
deps-latest-sf:
	cd $(SUPPORT_FIRECLOUD_DIR) && \
		bin/git-checkout-wbni origin/$(SUPPORT_FIRECLOUD_TRACKING_BRANCH)
