SRC_D_TS_FILES += \
	$(shell $(FIND_Q_NOSYM) src -type f -name "*.d.ts" -print) \

LIB_D_TS_FILES += \
	$(patsubst src/%.d.ts,lib/%.d.ts,$(SRC_D_TS_FILES)) \

YP_CLEAN_FILES += \
	$(LIB_D_TS_FILES) \

YP_BUILD_TARGETS += \
	build-cp-dts

# ------------------------------------------------------------------------------

$(LIB_D_TS_FILES): lib/%.d.ts: src/%.d.ts $(SRC_D_TS_FILES)
	$(MKDIR) $$(dirname $@)
	cp $< $@


.PHONY: build-cp-dts
build-cp-dts: $(LIB_D_TS_FILES)
