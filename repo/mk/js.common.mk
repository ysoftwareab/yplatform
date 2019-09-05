# This is a collection of "must have" targets for JavaScript repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))

include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/generic.common.mk

SF_JS_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.deps.npm.mk \

SF_JS_COMMON_INCLUDES = $(filter-out $(SF_INCLUDES_IGNORE), $(SF_JS_COMMON_INCLUDES_DEFAULT))

include $(SF_JS_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

PKG_NAME := $(shell $(CAT) package.json | $(JQ) -r ".name")
PKG_VSN := $(shell $(CAT) package.json | $(JQ) -r ".version")

SRC_JS_FILES := $(shell $(FIND_Q_NOSYM) src -type f -name "*.js" -print)

# ------------------------------------------------------------------------------
