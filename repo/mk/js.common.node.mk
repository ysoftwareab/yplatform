# NOTE placeholder. Should probably just be replaced with the two Makefiles below

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.common.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.build.babel.mk

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
