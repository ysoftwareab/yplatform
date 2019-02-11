TSC = $(call which,TSC,tsc)
$(foreach VAR,TSC,$(call make-lazy,$(VAR)))

TS_FILES = $(shell $(FIND_Q_NOSYM) src -type f -name "*.ts" -print)
TS_FILES_GEN = \
	$(patsubst %.ts,%.js,$(TS_FILES)) \
	$(patsubst %.ts,%.js.map,$(TS_FILES))

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	$(TS_FILES_GEN) \

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	build-ts \

# ------------------------------------------------------------------------------

.PHONY: build-ts
build-ts:
	$(TSC)
