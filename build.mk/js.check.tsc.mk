# Adds a 'check-tsc' internal target to run 'tsc --noEmit'.
# The 'check-tsc' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The tsc executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the tsc executable can be changed via TSC_ARGS.
#
# ------------------------------------------------------------------------------

TSLINT = $(call npm-which,TSLINT,tslint)
$(foreach VAR,TSLINT,$(call make-lazy-once,$(VAR)))

TSLINT_ARGS += \
	--format verbose \

YP_CHECK_TARGETS += \
	check-tsc \

YP_CHECK_TSC_PROJECT := tsconfig.check.json
ifeq ($(wildcard tsconfig.check.json),)
YP_CHECK_TSC_PROJECT := tsconfig.json
endif

TSC_ARGS += \

YP_CHECK_TSC_TSC_ARGS += \
	-p $(YP_CHECK_TSC_PROJECT) \
	--noEmit \

# ------------------------------------------------------------------------------

.PHONY: check-tsc
check-tsc:
	$(TSC) $(TSC_ARGS) $(YP_CHECK_TSC_TSC_ARGS)
