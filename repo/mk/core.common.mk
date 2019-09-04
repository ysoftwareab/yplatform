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

NODE_ESM = $(call which,NODE_ESM,node-esm)

# ------------------------------------------------------------------------------

.PHONY: all
all: deps build check ## Fetch dependencies, build and check.


include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.bootstrap.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.vendor.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.clean.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.deps.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.build.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.check.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.test.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.sf-update.mk
