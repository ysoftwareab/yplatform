# This is a collection of "bare minimum" targets for generic repositories.
#
# ------------------------------------------------------------------------------

YP_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST)))/..)

# ------------------------------------------------------------------------------

YP_CI_ECHO_BENCHMARK ?= /dev/null
YP_CI_ECHO ?= $(YP_DIR)/bin/ci-echo --benchmark $(YP_CI_ECHO_BENCHMARK)
include $(YP_DIR)/mk/common.inc.mk

YP_COMMIT =
YP_VSN = $(shell $(CAT) $(YP_DIR)/package.json | $(JQ) -r ".version")
YP_VSN_DESCRIBE = $(YP_VSN)-dirty
YP_VSN_TAG =
ifneq (,$(wildcard $(YP_DIR)/.git))
YP_COMMIT = $(shell 2>/dev/null $(GIT) -C $(YP_DIR) \
	rev-parse HEAD^{commit})
YP_VSN_DESCRIBE = $(shell 2>/dev/null $(GIT) -C $(YP_DIR) \
	describe --first-parent --always --dirty | $(SED) "s/^v//")
YP_VSN_TAG = $(shell 2>/dev/null $(GIT) -C $(YP_DIR) \
	tag --points-at HEAD | $(GREP) "s/^v//" 2>/dev/null | $(HEAD) -1)
endif
$(foreach VAR,YP_COMMIT YP_VSN YP_VSN_DESCRIBE YP_VSN_TAG,$(call make-lazy-once,$(VAR)))

# get yp-env environment variables
YP_ENV ?=
ifneq (true,$(YP_ENV))
$(warning Setting env vars based on .yp-env.mk generated from bin/yp-env .)
$(shell $(YP_DIR)/bin/yp-env >.yp-env.mk)
include .yp-env.mk
export $(shell $(SED) 's/=.\{0,\}//' .yp-env.mk)
endif

# get generic environment variables
ifneq (,$(wildcard .env))
$(warning Setting env vars based on .env .)
$(shell $(TEST) .env.mk -nt .env || $(CAT) .env | $(SED) "s/\\$$/\\$$\\$$/g" >.env.mk)
include .env.mk
export $(shell $(SED) 's/=.\{0,\}//' .env.mk)
endif

# get Makefile-specific environment variables
ifneq (,$(wildcard .makerc))
$(warning Setting env vars based on .makerc .)
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
	$(YP_DIR)/build.mk/core.vendor.mk \
	$(YP_DIR)/build.mk/core.clean.mk \
	$(YP_DIR)/build.mk/core.deps.mk \
	$(YP_DIR)/build.mk/core.build.mk \
	$(YP_DIR)/build.mk/core.check.mk \
	$(YP_DIR)/build.mk/core.shell.mk \
	$(YP_DIR)/build.mk/core.test.mk \

YP_CORE_COMMON_INCLUDES_DEFAULT += \
	$(YP_DIR)/build.mk/core.deps.git-info-attributes.mk \
	$(YP_DIR)/build.mk/core.deps.git-info-exclude.mk \
	$(YP_DIR)/build.mk/core.deps.git-submodules.mk \
	$(YP_DIR)/build.mk/core.deps.git-reset-mtime.mk \
	$(YP_DIR)/build.mk/core.deps.git-hooks.mk \

YP_CORE_COMMON_INCLUDES_DEFAULT += \
	$(YP_DIR)/build.mk/core.node.mk \

YP_CORE_COMMON_INCLUDES_DEFAULT += \
	$(YP_DIR)/build.mk/core.archive.mk \
	$(YP_DIR)/build.mk/core.ci.mk \

YP_CORE_COMMON_INCLUDES = $(filter-out $(YP_INCLUDES_IGNORE), $(YP_CORE_COMMON_INCLUDES_DEFAULT))

include $(YP_CORE_COMMON_INCLUDES)
