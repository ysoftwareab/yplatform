# This is a collection of "must have" targets for Python repositories.
#
# ------------------------------------------------------------------------------

# NOTE might be enough with core.common.mk
ifndef SF_GENERIC_COMMON_INCLUDES_DEFAULT
	$(error Please include generic.common.mk, before including py.common.mk .)
endif

SF_PY_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/py.deps.pipenv.mk \

SF_PY_COMMON_INCLUDES = $(filter-out $(SF_INCLUDES_IGNORE), $(SF_PY_COMMON_INCLUDES_DEFAULT))

include $(SF_PY_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

# .py filename should not contain dots or hyphens, but it can have underscores
SF_PATH_LINT_RE := ^[a-z0-9/.-]\+\|[a-z0-9/.-]*/[a-z0-9_]\+\.py$$

SF_PATH_FILES_IGNORE += \
	-e "^Pipfile$$" \
	-e "/Pipfile$$" \
	-e "^Pipfile.lock$$" \
	-e "/Pipfile.lock$$" \

PKG_NAME := unknown # FIXME
PKG_VSN := 0.0.0 # FIXME

# ------------------------------------------------------------------------------
