# This is a collection of "must have" targets for Python repositories.
#
# ------------------------------------------------------------------------------

# NOTE might be enough with core.common.mk
ifndef YP_GENERIC_COMMON_INCLUDES_DEFAULT
$(error Please include generic.common.mk, before including py.common.mk)
endif

YP_PY_COMMON_INCLUDES_DEFAULT += \
	$(YP_DIR)/build.mk/py.deps.pipenv.mk \

YP_PY_COMMON_INCLUDES = $(filter-out $(YP_INCLUDES_IGNORE), $(YP_PY_COMMON_INCLUDES_DEFAULT))

include $(YP_PY_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

# .py filename should not contain dots or hyphens, but it can have underscores
YP_PATH_LINT_RE := ^[a-z0-9/.-]\+\|[a-z0-9/.-]*/[a-z0-9_]\+\.py$$

YP_PATH_FILES_IGNORE += \
	-e "^Pipfile$$" \
	-e "/Pipfile$$" \
	-e "^Pipfile.lock$$" \
	-e "/Pipfile.lock$$" \

PKG_NAME := unknown # FIXME
PKG_VSN := 0.0.0 # FIXME

# ------------------------------------------------------------------------------
