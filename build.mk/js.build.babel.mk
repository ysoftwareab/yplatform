BABEL = $(call npm-which,BABEL,babel)
BABEL_NODE = $(call npm-which,BABEL_NODE,babel-node)
$(foreach VAR,BABEL BABEL_NODE,$(call make-lazy-once,$(VAR)))

BABELRC := $(shell $(FIND_Q_NOSYM) . -mindepth 0 -maxdepth 1 -name ".babelrc*" -print)

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

YP_CLEAN_FILES += \
	$(LIB_JS_FILES) \
	$(LIB_JS_MAP_FILES) \

YP_BUILD_TARGETS += \
	build-babel \

BABEL_ARGS += \
	--source-maps

# ------------------------------------------------------------------------------

$(LIB_JS_FROM_JS_FILES): lib/%.js: src/%.js $(SRC_JS_FILES) $(BABELRC)
	$(MKDIR) $$(dirname $@)
	$(BABEL) $< $(BABEL_ARGS) --out-file $@


$(LIB_JS_FROM_TS_FILES): lib/%.js: src/%.ts $(SRC_JS_FILES) $(BABELRC)
	$(MKDIR) $$(dirname $@)
	$(BABEL) $< $(BABEL_ARGS) --out-file $@


.PHONY: build-babel
build-babel:
	YP_BABEL_FILES_TMP=($(LIB_JS_FROM_JS_FILES) $(LIB_JS_FROM_TS_FILES)); \
	[[ "$${#YP_BABEL_FILES_TMP[@]}" = "0" ]] || { \
		$(MAKE) --no-print-directory $${YP_BABEL_FILES_TMP[@]}; \
	}
