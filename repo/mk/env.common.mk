# This is a collection of "must have" targets for repositories with environments.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/env.promote.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/env.teardown.mk

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
