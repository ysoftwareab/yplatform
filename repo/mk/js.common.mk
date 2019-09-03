# This is a collection of "must have" targets for JavaScript repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/generic.common.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.deps.npm.mk

# ------------------------------------------------------------------------------

NODE = $(call which,NODE,node)
NODE_NPM = $(shell realpath $(NODE) | $(SED) "s/bin\/node\$$/libexec\/npm\/bin\/npm/")
NODE_NPX = $(shell realpath $(NODE) | $(SED) "s/bin\/node\$$/libexec\/npm\/bin\/npx/")
NPM = $(call which,NPM,npm)
NPX = $(call which,NPX,npx)
$(foreach VAR,NODE NODE_NPM NODE_NPX NPM NPX,$(call make-lazy,$(VAR)))

PKG_NAME := $(shell $(CAT) package.json | $(JQ) -r ".name")
PKG_VSN := $(shell $(CAT) package.json | $(JQ) -r ".version")

SRC_JS_FILES := $(shell $(FIND_Q_NOSYM) src -type f -name "*.js" -print)

# ------------------------------------------------------------------------------
