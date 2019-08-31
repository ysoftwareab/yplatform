# Adds targets to generate the BUILD and VERSION files,
# which include variables that can be sourced by shell scripts and Makefiles.

# ------------------------------------------------------------------------------

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	BUILD \
	VERSION \

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	VERSION \

BUILD_DATE ?= $(MAKE_DATE)
BUILD_TIME ?= $(MAKE_TIME)

BUILD_HOSTNAME ?= $(shell hostname)
BUILD_USER ?= $(shell whoami)
$(foreach VAR,BUILD_HOSTNAME BUILD_USER,$(call make-lazy,$(VAR)))

BUILD_GIT_BRANCH ?= $(GIT_BRANCH_SHORT)
BUILD_GIT_DESCRIBE ?= $(GIT_DESCRIBE)
BUILD_GIT_HASH ?= $(GIT_HASH_SHORT)
BUILD_GIT_TAGS ?= $(subst $( ),$(,),$(GIT_TAGS))
BUILD_OS ?= $(OS)
BUILD_OS_ARCH ?= $(ARCH)
BUILD_VSN ?= $(PKG_VSN)_$(GIT_HASH)


SF_BUILD_VARS := \
	BUILD_VSN \
	BUILD_DATE \
	BUILD_TIME \
	BUILD_GIT_BRANCH \
	BUILD_GIT_DESCRIBE \
	BUILD_GIT_HASH \
	BUILD_GIT_TAGS \
	BUILD_OS \
	BUILD_OS_ARCH \
	BUILD_USER \
	BUILD_HOSTNAME \

SF_VERSION_VARS := \
	PKG_NAME \
	PKG_VSN \

define sf-write-var-to-file
	$(ECHO)  | $(TEE) -a $2
endef


# ------------------------------------------------------------------------------

.PHONY: BUILD
BUILD:
	$(ECHO_DO) "Generating $@..."
	$(RM) $@
	$(ECHO) $(foreach VAR,$(SF_BUILD_VARS),"$(VAR)=$($(VAR))") | $(TR) ' ' '\n' > $@
	$(ECHO_DONE)


VERSION: BUILD
	$(ECHO_DO) "Generating $@..."
	$(RM) $@
	$(ECHO) $(foreach VAR,$(SF_VERSION_VARS),"$(VAR)=$($(VAR))") | $(TR) ' ' '\n' > $@
	$(CAT) BUILD >> $@
	$(ECHO_DONE)
