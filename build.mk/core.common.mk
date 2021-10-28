# This is a collection of "bare minimum" targets for generic repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST)))/..)

# ------------------------------------------------------------------------------

ifndef YP_DEV_INC_SH
ifeq (0,$(MAKELEVEL))
NVM_DIR := $(shell $(SUPPORT_FIRECLOUD_DIR)/bin/sf-env NVM_DIR)
PATH := $(shell $(SUPPORT_FIRECLOUD_DIR)/bin/sf-env PATH)
export NVM_DIR PATH
endif
endif

YP_CI_ECHO_BENCHMARK ?= /dev/null
YP_CI_ECHO ?= $(SUPPORT_FIRECLOUD_DIR)/bin/ci-echo --benchmark $(YP_CI_ECHO_BENCHMARK)
include $(SUPPORT_FIRECLOUD_DIR)/mk/Makefile

YP_COMMIT =
YP_VSN = $(shell $(CAT) $(SUPPORT_FIRECLOUD_DIR)/package.json | $(JQ) -r ".version")
YP_VSN_DESCRIBE = $(YP_VSN)-dirty
YP_VSN_TAG =
ifneq (,$(wildcard $(SUPPORT_FIRECLOUD_DIR)/.git))
YP_COMMIT = $(shell 2>/dev/null $(GIT) -C $(SUPPORT_FIRECLOUD_DIR) \
	rev-parse HEAD^{commit})
YP_VSN_DESCRIBE = $(shell 2>/dev/null $(GIT) -C $(SUPPORT_FIRECLOUD_DIR) \
	describe --first-parent --always --dirty | $(SED) "s/^v//")
YP_VSN_TAG = $(shell 2>/dev/null $(GIT) -C $(SUPPORT_FIRECLOUD_DIR) \
	tag --points-at HEAD | $(GREP) "s/^v//" 2>/dev/null | $(HEAD) -1)
endif
$(foreach VAR,YP_COMMIT YP_VSN YP_VSN_DESCRIBE YP_VSN_TAG,$(call make-lazy-once,$(VAR)))

# get generic environment variables
ifneq (,$(wildcard .env))
$(shell $(TEST) .env.mk -nt .env || $(CAT) .env | $(SED) "s/\\$$/\\$$\\$$/g" >.env.mk)
include .env.mk
export $(shell $(SED) 's/=.\{0,\}//' .env.mk)
endif

# get Makefile-specific environment variables
ifneq (,$(wildcard .makerc))
include .makerc
endif

# NOTE use npm package.json by default with 'name' and 'version', even if the project is not using npm
PKG_NAME ?= $(shell $(CAT) package.json | $(JQ) -r ".name")
PKG_VSN ?= $(shell $(CAT) package.json | $(JQ) -r ".version")
$(foreach VAR,PKG_NAME PKG_VSN,$(call make-lazy-once,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: all
all: deps build check ## Fetch dependencies, build and check.

YP_INCLUDES_IGNORE ?=

YP_CORE_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.vendor.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.clean.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.deps.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.build.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.check.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.shell.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.test.mk \

YP_CORE_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.deps.git-info-attributes.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.deps.git-info-exclude.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.deps.git-submodules.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.deps.git-reset-mtime.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.deps.git-hook-pre-push.mk \

YP_CORE_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.node.mk \

YP_CORE_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.archive.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.ci.mk \

YP_CORE_COMMON_INCLUDES = $(filter-out $(YP_INCLUDES_IGNORE), $(YP_CORE_COMMON_INCLUDES_DEFAULT))

include $(YP_CORE_COMMON_INCLUDES)
