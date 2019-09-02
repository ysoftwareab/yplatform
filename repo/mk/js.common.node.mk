# This is a collection of "must have" targets for NodeJS repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.common.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.build.babel.mk

# ------------------------------------------------------------------------------

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	dist \
	lib \

# ------------------------------------------------------------------------------
