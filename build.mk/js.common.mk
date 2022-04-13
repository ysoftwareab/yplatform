# This is a collection of "must have" targets for JavaScript repositories.
#
# ------------------------------------------------------------------------------

# NOTE might be enough with core.common.mk
ifndef YP_GENERIC_COMMON_INCLUDES_DEFAULT
$(error Please include generic.common.mk, before including js.common.mk)
endif

YP_JS_COMMON_INCLUDES_DEFAULT += \
	$(YP_DIR)/build.mk/js.deps.npm.mk \

YP_JS_COMMON_INCLUDES = $(filter-out $(YP_INCLUDES_IGNORE), $(YP_JS_COMMON_INCLUDES_DEFAULT))

include $(YP_JS_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

TSC = $(call npm-which,TSC,tsc)
$(foreach VAR,TSC,$(call make-lazy-once,$(VAR)))

SRC_JS_FILES := $(shell $(FIND_Q_NOSYM) src -type f -name "*.js" -print)

SRC_TS_FILES := $(shell $(FIND_Q_NOSYM) src -type f -name "*.ts" -print)

# ------------------------------------------------------------------------------
