# Adds a 'check-tsc' internal target to run 'tsc --noEmit'.
# The 'check-tsc' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# The tsc executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the tsc executable can be changed via TSC_ARGS.
#
# ------------------------------------------------------------------------------

TSLINT = $(call npm-which,TSLINT,tslint)
$(foreach VAR,TSLINT,$(call make-lazy,$(VAR)))

TSLINT_ARGS += \
	--format verbose \

SF_CHECK_TARGETS += \
	check-tsc \

TSC_ARGS += \

# ------------------------------------------------------------------------------

.PHONY: check-tsc
check-tsc:
	$(TSC) --noEmit $(TSC_ARGS)
