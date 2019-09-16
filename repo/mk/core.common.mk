# This is a collection of "bare minimum" targets for generic repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))

# ------------------------------------------------------------------------------

PATH := $(PATH):$(SUPPORT_FIRECLOUD_DIR)/bin
export PATH

CI_ECHO ?= $(SUPPORT_FIRECLOUD_DIR)/bin/ci-echo
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.inc.mk/Makefile

ifdef TRAVIS_BRANCH
GIT_BRANCH = $(TRAVIS_BRANCH)
endif

# makefile-folder node_modules exebutables
PATH_NPM := $(MAKE_PATH)/node_modules/.bin
# repository node_modules executables
PATH_NPM := $(PATH_NPM):$(GIT_ROOT)/node_modules/.bin

define npm-which
$(shell \
	export PATH="$(PATH_NPM):$(PATH)"; \
	export RESULT="$$(for CMD in $(2); do $(WHICH_Q) $${CMD} && break || continue; done)"; \
	echo "$${RESULT:-$(1)_NOT_FOUND}")
endef

NODE = $(call which,NODE,node)
NODE_ESM = $(call which,NODE_ESM,node-esm)
NODE_NPM = $(shell $(REALPATH) $(NODE) | $(SED) "s/bin\/node\$$/libexec\/npm\/bin\/npm/")
NODE_NPX = $(shell $(REALPATH) $(NODE) | $(SED) "s/bin\/node\$$/libexec\/npm\/bin\/npx/")
NPM = $(call which,NPM,npm)
NPX = $(call which,NPX,npx)
$(foreach VAR,NODE NODE_ESM NODE_NPM NODE_NPX NPM NPX,$(call make-lazy,$(VAR)))

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

SF_CORE_COMMON_INCLUDES = $(filter-out $(SF_INCLUDES_IGNORE), $(SF_CORE_COMMON_INCLUDES_DEFAULT))

include $(SF_CORE_COMMON_INCLUDES)
