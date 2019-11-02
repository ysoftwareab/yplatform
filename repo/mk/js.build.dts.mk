LIB_DTS_FILES += \
	$(patsubst src/%.js,lib/%.d.ts,$(SRC_JS_FILES)) \
	$(patsubst src/%.ts,lib/%.d.ts,$(SRC_TS_FILES)) \

SF_CLEAN_FILES += \
	$(LIB_DTS_FILES) \

SF_BUILD_TARGETS += \
	build-dts \

TSC_ARGS += \

# ------------------------------------------------------------------------------

.PHONY: build-dts
build-dts:
	$(TSC) --emitDeclarationOnly $(TSC_ARGS)
