# Adds 'BUILD' and 'VERSION' internal targets to generate the respective files,
# which include variables that can be sourced by shell scripts and Makefiles.
# The 'BUILD' and 'VERSION' targets are automatically included in the 'build' target via YP_BUILD_TARGETS.
#
# ------------------------------------------------------------------------------
#
# Adds a 'yp-substitute-version-vars-in-file' function
# that can generate files based on templates
# that reference variables in the BUILD or VERSION files.
# This is useful for referencing version information at runtime.
# Usage:
#
# some/version.js: some/tpl.version.js
#	$(call yp-substitute-version-vars-in-file,$<,$@)
#
# where 'some/tpl.version.js' could be:
# export default {gitHash: '${BUILD_GIT_HASH}'};
#
# ------------------------------------------------------------------------------

YP_CLEAN_FILES += \
	BUILD \
	VERSION \

YP_BUILD_TARGETS += \
	VERSION \

BUILD_DATE ?= $(MAKE_DATE)
BUILD_TIME ?= $(MAKE_TIME)

BUILD_HOSTNAME ?= $(shell hostname)
BUILD_USER ?= $(shell whoami)
$(foreach VAR,BUILD_HOSTNAME BUILD_USER,$(call make-lazy-once,$(VAR)))

BUILD_GIT_BRANCH ?= $(GIT_BRANCH_SHORT)
BUILD_GIT_DESCRIBE ?= $(GIT_DESCRIBE)
BUILD_GIT_HASH ?= $(GIT_HASH)
BUILD_GIT_TAGS ?= $(subst $( ),$(,),$(GIT_TAGS))
BUILD_OS ?= $(OS_SHORT)
BUILD_OS_ARCH ?= $(ARCH)
BUILD_OS_SYSTEM ?= $(shell $(UNAME) -a)
BUILD_VSN ?= $(PKG_VSN)_$(GIT_HASH)


YP_BUILD_VARS = \
	BUILD_VSN \
	BUILD_DATE \
	BUILD_TIME \
	BUILD_GIT_BRANCH \
	BUILD_GIT_DESCRIBE \
	BUILD_GIT_HASH \
	BUILD_GIT_TAGS \
	BUILD_OS \
	BUILD_OS_ARCH \
	BUILD_OS_SYSTEM \
	BUILD_USER \
	BUILD_HOSTNAME \

YP_VERSION_VARS = \
	PKG_NAME \
	PKG_VSN \
	$(YP_BUILD_VARS)

define yp-substitute-version-vars-in-file
	< $1 > $2 \
		$(foreach VAR,$(YP_VERSION_VARS),$(VAR)=$($(VAR))) \
		$(ENVSUBST) '$(foreach VAR,$(YP_VERSION_VARS),$${$(VAR)})'
endef

# ------------------------------------------------------------------------------

.PHONY: BUILD
BUILD:
	$(ECHO_DO) "Generating $@..."
	$(RM) $@
	$(ECHO) $(foreach VAR,$(YP_BUILD_VARS),"$(VAR)=$($(VAR))") | $(TR) ' ' '\n' > $@
	$(ECHO_DONE)


VERSION: BUILD
	$(ECHO_DO) "Generating $@..."
	$(RM) $@
	$(ECHO) $(foreach VAR,$(YP_VERSION_VARS),"$(VAR)=$($(VAR))") | $(TR) ' ' '\n' > $@
	$(ECHO_DONE)
