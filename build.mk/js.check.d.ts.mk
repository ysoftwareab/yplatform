# Adds a 'check-d-ts' target to run 'tsc'
# over YP_D_TS_FILES (defaults to all committed and staged *.d.ts files).
# The 'check-d-ts' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# The tsc executable is lazy-found inside node_modules/.bin and $PATH.
# The arguments to the tsc executable can be changed via TSC_D_TS_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_D_TS_FILES_IGNORE:
# YP_D_TS_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

YP_IS_TRANSCRYPTED ?= false

TSC_D_TS = $(call npm-which,TSC,tsc)
$(foreach VAR,TSC_D_TS,$(call make-lazy-once,$(VAR)))

TSC_D_TS_ARGS += \
	--esModuleInterop \
	--noEmit \

YP_D_TS_FILES_IGNORE += \
	-e "^$$" \
	$(YP_VENDOR_FILES_IGNORE) \

YP_D_TS_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\.d\.ts$$" | \
	$(GREP) -Fvxf <($(FIND) $(GIT_ROOT) -type l -printf "%P\n") | \
	$(GREP) -Fvxf <($(YP_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(YP_D_TS_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

YP_CHECK_TARGETS += \
	check-d-ts

# ------------------------------------------------------------------------------

.PHONY: check-d-ts
check-d-ts:
	$(TSC_D_TS) $(TSC_D_TS_ARGS) $(YP_D_TS_FILES)
