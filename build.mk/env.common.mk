# This is a collection of "must have" targets for repositories with "environments",
# like "cloud" apps.
#
# The convention states that such a repository can have multiple live environments,
# all driven by the "env/<name>" branches.
#
# Promoting a tag to such a branch should be followed by the CI picking up the push,
# and deploying that tag's artifacts to the respective named environment.
#
# ------------------------------------------------------------------------------

# NOTE might be enough with core.common.mk
ifndef YP_GENERIC_COMMON_INCLUDES_DEFAULT
$(error Please include generic.common.mk, before including env.common.mk .)
endif

include $(YP_DIR)/build.mk/env.promote.mk
include $(YP_DIR)/build.mk/env.teardown.mk

# ------------------------------------------------------------------------------

YP_PROMOTE_ENVS += \
	dev \
	prod-staging \
	prod \


# ------------------------------------------------------------------------------
