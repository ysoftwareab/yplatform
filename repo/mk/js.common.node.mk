# This is a collection of "must have" targets for NodeJS repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))

include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.common.mk

SF_NODE_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.build.babel.mk \

SF_NODE_COMMON_INCLUDES = $(filter-out $(SF_INCLUDES_IGNORE), $(SF_NODE_COMMON_INCLUDES_DEFAULT))

include $(SF_NODE_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

SF_CLEAN_FILES += \
	dist \
	lib \

# ------------------------------------------------------------------------------
