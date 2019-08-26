SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/../..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/generic.common.mk
include $(SUPPORT_FIRECLOUD_DIR)/repo/mk/py.deps.pipenv.mk

# ------------------------------------------------------------------------------

# .py filename should not contain dots or hyphens, but it can have underscores
SF_PATH_LINT_RE := ^[a-z0-9/.-]\+\|[a-z0-9/.-]*/[a-z0-9_]\+\.py$$

SF_PATH_FILES_IGNORE := \
	$(SF_PATH_FILES_IGNORE) \
	-e "^Pipfile$$" \
	-e "/Pipfile$$" \

PKG_NAME := unknown # FIXME
PKG_VSN := 0.0.0 # FIXME

# ------------------------------------------------------------------------------
