SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/generic.common.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.deps.npm.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.misc.version.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.misc.release.mk

# ------------------------------------------------------------------------------

PATH := $(MAKE_PATH)/node_modules/.bin:$(GIT_ROOT)/node_modules/.bin:$(PATH)
export PATH

NODE = $(call which,NODE,node)
NODE_NPM = $(shell realpath $(NODE) | $(SED) "s/bin\/node\$$/libexec\/npm\/bin\/npm/")
NODE_NPX = $(shell realpath $(NODE) | $(SED) "s/bin\/node\$$/libexec\/npm\/bin\/npx/")
NPM = $(call which,NPM,npm)
NPX = $(call which,NPX,npx)
$(foreach VAR,NODE NODE_NPM NODE_NPX NPM NPX,$(call make-lazy,$(VAR)))

SRC_JS_FILES := $(shell $(FIND_Q) src -type f -name "*.js" -print)

# ------------------------------------------------------------------------------
