# This is a collection of "must have" targets for environment repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/env.promote-tag-to-env-branch.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/env.teardown.mk

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
