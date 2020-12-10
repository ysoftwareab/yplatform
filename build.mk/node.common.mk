# This is a collection of "must have" targets for NodeJS repositories.
#
# ------------------------------------------------------------------------------

# NOTE might be enough with core.common.mk
ifndef SF_GENERIC_COMMON_INCLUDES_DEFAULT
$(error Please include generic.common.mk, before including node.common.mk .)
endif

include $(SUPPORT_FIRECLOUD_DIR)/build.mk/js.common.mk

SF_NODE_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/js.build.babel.mk \

SF_NODE_COMMON_INCLUDES = $(filter-out $(SF_INCLUDES_IGNORE), $(SF_NODE_COMMON_INCLUDES_DEFAULT))

include $(SF_NODE_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

SF_CLEAN_FILES += \
	dist \
	lib \

# ------------------------------------------------------------------------------
