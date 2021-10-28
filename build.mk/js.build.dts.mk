LIB_DTS_FILES += \
	$(patsubst src/%.js,lib/%.d.ts,$(SRC_JS_FILES)) \
	$(patsubst src/%.ts,lib/%.d.ts,$(SRC_TS_FILES)) \

YP_CLEAN_FILES += \
	$(LIB_DTS_FILES) \

YP_BUILD_TARGETS += \
	build-dts \

YP_BUILD_DTS_PROJECT := tsconfig.declaration.json
ifeq ($(wildcard tsconfig.declaration.json),)
YP_BUILD_DTS_PROJECT := tsconfig.json
endif

TSC_ARGS += \

YP_BUILD_DTS_TSC_ARGS += \
	-p $(YP_BUILD_DTS_PROJECT) \
	--emitDeclarationOnly \

# ------------------------------------------------------------------------------

.PHONY: build-dts
build-dts:
	$(TSC) $(TSC_ARGS) $(YP_BUILD_DTS_TSC_ARGS)
