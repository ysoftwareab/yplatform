SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	BUILD \
	VERSION \

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	VERSION \

BUILD_GIT_BRANCH ?= $(GIT_BRANCH_SHORT)
BUILD_GIT_DESCRIBE ?= $(GIT_DESCRIBE)
BUILD_GIT_HASH ?= $(GIT_HASH_SHORT)
BUILD_HOSTNAME ?= $(shell hostname)
BUILD_OS ?= $(OS)
BUILD_OS_ARCH ?= $(ARCH)
BUILD_USER ?= $(shell whoami)
BUILD_VSN ?= $(PKG_VSN)_$(GIT_HASH)
$(foreach VAR,BUILD_HOSTNAME BUILD_USER,$(call make-lazy,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: BUILD
BUILD:
	$(ECHO_DO) "Generating $@..."
	$(RM) $@
	$(ECHO) "BUILD_VSN=$(BUILD_VSN)" >> $@
	$(ECHO) "BUILD_DATE=$(MAKE_DATE)" >> $@
	$(ECHO) "BUILD_TIME=$(MAKE_TIME)" >> $@
	$(ECHO) "BUILD_GIT_HASH=$(BUILD_GIT_HASH)" >> $@
	$(ECHO) "BUILD_GIT_BRANCH=$(BUILD_GIT_BRANCH)" >> $@
	$(ECHO) "BUILD_GIT_DESCRIBE=$(BUILD_GIT_DESCRIBE)" >> $@
	$(ECHO) "BUILD_OS=$(BUILD_OS)" >> $@
	$(ECHO) "BUILD_OS_ARCH=$(BUILD_OS_ARCH)" >> $@
	$(ECHO) "BUILD_USER=$(BUILD_USER)" >> $@
	$(ECHO) "BUILD_HOSTNAME=$(BUILD_HOSTNAME)" >> $@
	$(ECHO_DONE)


VERSION: BUILD
	$(ECHO_DO) "Generating $@..."
	$(RM) $@
	$(ECHO) "PKG_NAME=$(PKG_NAME)" >> $@
	$(ECHO) "PKG_VSN=$(PKG_VSN)" >> $@
	$(CAT) BUILD >> $@
	$(ECHO_DONE)
