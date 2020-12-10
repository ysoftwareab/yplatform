# This is a collection of "must have" targets for generic repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST)))/..)
include $(SUPPORT_FIRECLOUD_DIR)/build.mk/core.common.mk

SF_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.deps.git-hook-pre-push.mk \

SF_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.build.build-version-files.mk \

SF_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.check.path.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.check.tpl.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.check.eclint.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.check.jsonlint.mk \

# core.misc.release.mk depends on core.misc.version.mk
SF_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.misc.promote.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.misc.version.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.misc.release.mk \

SF_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.misc.docker-ci.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.misc.bootstrap.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.misc.sf-update.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.misc.snapshot.mk \
	$(SUPPORT_FIRECLOUD_DIR)/build.mk/core.misc.transcrypt.mk \

SF_GENERIC_COMMON_INCLUDES = $(filter-out $(SF_INCLUDES_IGNORE), $(SF_GENERIC_COMMON_INCLUDES_DEFAULT))

include $(SF_GENERIC_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
