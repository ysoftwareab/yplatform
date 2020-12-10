LIB_JS_FROM_JS_FILES += \
	$(patsubst src/%.js,lib/%.js,$(SRC_JS_FILES)) \

LIB_JS_FROM_TS_FILES += \
	$(patsubst src/%.ts,lib/%.js,$(SRC_TS_FILES)) \

LIB_JS_FILES += \
	$(LIB_JS_FROM_JS_FILES) \
	$(LIB_JS_FROM_TS_FILES) \

LIB_JS_MAP_FILES += \
	$(patsubst src/%.js,lib/%.js.map,$(SRC_JS_FILES)) \
	$(patsubst src/%.ts,lib/%.js.map,$(SRC_TS_FILES)) \

LIB_DTS_FILES += \
	$(patsubst src/%.js,lib/%.d.ts,$(SRC_JS_FILES)) \
	$(patsubst src/%.ts,lib/%.d.ts,$(SRC_TS_FILES)) \

SF_CLEAN_FILES += \
	$(LIB_JS_FILES) \
	$(LIB_JS_MAP_FILES) \
	$(LIB_DTS_FILES) \

SF_BUILD_TARGETS += \
	build-ts \

TSC_ARGS += \

# ------------------------------------------------------------------------------

.PHONY: build-ts
build-ts:
	$(TSC) $(TSC_ARGS)
