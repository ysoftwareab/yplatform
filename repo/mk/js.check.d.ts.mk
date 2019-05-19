TSC = $(call npm-which,TSC,tsc)
$(foreach VAR,TSC,$(call make-lazy,$(VAR)))

SRC_D_TS_FILES := $(shell $(FIND_Q_NOSYM) src -type f -name "*.d.ts" -print)

SF_CHECK_TARGETS := \
	$(SF_CHECK_TARGETS) \
	check-d-ts

# ------------------------------------------------------------------------------

.PHONY: check-d-ts
check-d-ts:
	$(TSC) --esModuleInterop --noEmit $(SRC_D_TS_FILES)
