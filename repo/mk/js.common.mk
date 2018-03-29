SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/generic.common.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.deps.npm.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.misc.version.mk

PATH := $(MAKE_PATH)/node_modules/.bin:$(GIT_ROOT)/node_modules/.bin:$(PATH)
export PATH

JS_FILES_IGNORE := \
	-e "^$$"

JS_FILES = $(shell $(GIT_LS) | \
	$(GREP) -v $(JS_FILES_IGNORE) | \
	$(GREP) -e ".js$$" | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SRC_JS_FILES := $(shell $(FIND_Q) src -type f -name "*.js" -print)

# ------------------------------------------------------------------------------
