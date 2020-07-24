# This is a collection of "bare minimum" targets for generic repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST)))/../..)

# ------------------------------------------------------------------------------

PATH := $(PATH):$(SUPPORT_FIRECLOUD_DIR)/bin
export PATH

CI_ECHO ?= $(SUPPORT_FIRECLOUD_DIR)/bin/ci-echo
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.inc.mk/Makefile

SF_COMMIT :=
SF_VSN := $(shell $(CAT) $(SUPPORT_FIRECLOUD_DIR)/package.json | $(JQ) -r ".version")
SF_VSN_DESCRIBE := $(SF_VSN)-dirty
SF_VSN_TAG :=
ifneq (,$(wildcard $(SUPPORT_FIRECLOUD_DIR)/.git))
SF_COMMIT := $(shell $(GIT) -C $(SUPPORT_FIRECLOUD_DIR) \
	rev-parse HEAD^{commit} 2>/dev/null)
SF_VSN_DESCRIBE := $(shell $(GIT) -C $(SUPPORT_FIRECLOUD_DIR) \
	describe --first-parent --always --dirty 2>/dev/null | $(SED) "s/^v//")
SF_VSN_TAG := $(shell $(GIT) -C $(SUPPORT_FIRECLOUD_DIR) \
	tag -l --points-at HEAD 2>/dev/null | $(GREP) "s/^v//" 2>/dev/null | $(HEAD) -1)
endif

# get generic environment variables
ifneq (,$(wildcard .env))
include .env
export $(shell sed 's/=.*//' .env)
endif

# get Makefile-specific environment variables
ifneq (,$(wildcard .makerc))
include .makerc
endif

ifdef TRAVIS_BRANCH
GIT_BRANCH = $(TRAVIS_BRANCH)
endif

# NOTE use npm package.json by default with 'name' and 'version', even if the project is not using npm
PKG_NAME ?= $(shell $(CAT) package.json | $(JQ) -r ".name")
PKG_VSN ?= $(shell $(CAT) package.json | $(JQ) -r ".version")
$(foreach VAR,PKG_NAME PKG_VSN,$(call make-lazy,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: all
all: deps build check ## Fetch dependencies, build and check.

SF_INCLUDES_IGNORE ?=

SF_CORE_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.vendor.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.clean.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.deps.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.build.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.check.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.shell.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.test.mk \

SF_CORE_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.node.mk \

SF_CORE_COMMON_INCLUDES = $(filter-out $(SF_INCLUDES_IGNORE), $(SF_CORE_COMMON_INCLUDES_DEFAULT))

include $(SF_CORE_COMMON_INCLUDES)
