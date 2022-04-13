# This is a collection of "must have" targets for NodeJS repositories.
#
# ------------------------------------------------------------------------------

# NOTE might be enough with core.common.mk
ifndef YP_GENERIC_COMMON_INCLUDES_DEFAULT
$(error Please include generic.common.mk, before including node.common.mk)
endif

include $(YP_DIR)/build.mk/js.common.mk

YP_NODE_COMMON_INCLUDES_DEFAULT += \
	$(YP_DIR)/build.mk/js.build.babel.mk \

YP_NODE_COMMON_INCLUDES = $(filter-out $(YP_INCLUDES_IGNORE), $(YP_NODE_COMMON_INCLUDES_DEFAULT))

include $(YP_NODE_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

YP_CLEAN_FILES += \
	dist \
	lib \

# ------------------------------------------------------------------------------
