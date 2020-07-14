# This is a collection of "bare minimum" targets for generic repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))

# ------------------------------------------------------------------------------

PATH := $(PATH):$(SUPPORT_FIRECLOUD_DIR)/bin
export PATH

CI_ECHO ?= $(SUPPORT_FIRECLOUD_DIR)/bin/ci-echo
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.inc.mk/Makefile

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
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.test.mk \

SF_CORE_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.node.mk \

SF_CORE_COMMON_INCLUDES = $(filter-out $(SF_INCLUDES_IGNORE), $(SF_CORE_COMMON_INCLUDES_DEFAULT))

include $(SF_CORE_COMMON_INCLUDES)
