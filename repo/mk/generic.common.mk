# This is a collection of "must have" targets for generic repositories.
#
# ------------------------------------------------------------------------------

SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.common.mk

include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.deps.git-hook-pre-push.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.build-version-file.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.check.path.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.check.eclint.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.check.jsonlint.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.transcrypt.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.bootstrap.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.release.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.snapshot.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.version.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/core.misc.sf-update.mk

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
