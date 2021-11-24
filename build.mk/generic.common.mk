# This is a collection of "must have" targets for generic repositories.
#
# ------------------------------------------------------------------------------

YP_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST)))/..)
include $(YP_DIR)/build.mk/core.common.mk

YP_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(YP_DIR)/build.mk/core.build.build-version-files.mk \

YP_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(YP_DIR)/build.mk/core.check.path.mk \
	$(YP_DIR)/build.mk/core.check.path-sensitive.mk \
	$(YP_DIR)/build.mk/core.check.symlinks.mk \
	$(YP_DIR)/build.mk/core.check.tpl.mk \
	$(YP_DIR)/build.mk/core.check.editorconfig.mk \
	$(YP_DIR)/build.mk/core.check.jsonlint.mk \

# core.misc.release.mk depends on core.misc.version.mk
YP_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(YP_DIR)/build.mk/core.misc.promote.mk \
	$(YP_DIR)/build.mk/core.misc.version.mk \
	$(YP_DIR)/build.mk/core.misc.release.mk \

YP_GENERIC_COMMON_INCLUDES_DEFAULT += \
	$(YP_DIR)/build.mk/core.misc.docker-ci.mk \
	$(YP_DIR)/build.mk/core.misc.bootstrap.mk \
	$(YP_DIR)/build.mk/core.misc.yp-update.mk \
	$(YP_DIR)/build.mk/core.misc.snapshot.mk \
	$(YP_DIR)/build.mk/core.misc.transcrypt.mk \

YP_GENERIC_COMMON_INCLUDES = $(filter-out $(YP_INCLUDES_IGNORE), $(YP_GENERIC_COMMON_INCLUDES_DEFAULT))

include $(YP_GENERIC_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
