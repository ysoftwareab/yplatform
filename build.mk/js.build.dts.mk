LIB_DTS_FILES += \
	$(patsubst src/%.js,lib/%.d.ts,$(SRC_JS_FILES)) \
	$(patsubst src/%.ts,lib/%.d.ts,$(SRC_TS_FILES)) \

SF_CLEAN_FILES += \
	$(LIB_DTS_FILES) \

SF_BUILD_TARGETS += \
	build-dts \

SF_BUILD_DTS_PROJECT := tsconfig.declaration.json
ifeq ($(wildcard tsconfig.declaration.json),)
SF_BUILD_DTS_PROJECT := tsconfig.json
endif

TSC_ARGS += \

SF_BUILD_DTS_TSC_ARGS += \
	-p $(SF_BUILD_DTS_PROJECT) \
	--emitDeclarationOnly \

# ------------------------------------------------------------------------------

.PHONY: build-dts
build-dts:
	$(TSC) $(TSC_ARGS) $(SF_BUILD_DTS_TSC_ARGS)
