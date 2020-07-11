# This is a collection of "must have" targets for JavaScript repositories.
#
# ------------------------------------------------------------------------------

# NOTE might be enough with core.common.mk
ifndef SF_GENERIC_COMMON_INCLUDES_DEFAULT
	$(error Please include generic.common.mk, before including js.common.mk .)
endfi

SF_JS_COMMON_INCLUDES_DEFAULT += \
	$(SUPPORT_FIRECLOUD_DIR)/repo/mk/js.deps.npm.mk \

SF_JS_COMMON_INCLUDES = $(filter-out $(SF_INCLUDES_IGNORE), $(SF_JS_COMMON_INCLUDES_DEFAULT))

include $(SF_JS_COMMON_INCLUDES)

# ------------------------------------------------------------------------------

TSC = $(call npm-which,TSC,tsc)
$(foreach VAR,TSC,$(call make-lazy,$(VAR)))

SRC_JS_FILES := $(shell $(FIND_Q_NOSYM) src -type f -name "*.js" -print)

SRC_TS_FILES := $(shell $(FIND_Q_NOSYM) src -type f -name "*.ts" -print)

# ------------------------------------------------------------------------------
