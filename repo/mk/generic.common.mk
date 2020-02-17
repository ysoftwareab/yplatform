# This is a collection of "must have" targets for generic repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.common.mk

SF_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.deps.git-hook-pre-push.mk \

SF_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.build.build-version-files.mk \

SF_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.check.path.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.check.eclint.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.check.jsonlint.mk \

# core.misc.release.mk depends on core.misc.version.mk
SF_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.version.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.release.mk \

SF_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.bootstrap.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.sf-update.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.snapshot.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.transcrypt.mk \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.docker-ci.mk \

SF_GENERIC_COMMON_INCLUDES = $(filter-out $(SF_INCLUDES_IGNORE), $(SF_GENERIC_COMMON_INCLUDES_DEFAULT))

include $(SF_GENERIC_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
