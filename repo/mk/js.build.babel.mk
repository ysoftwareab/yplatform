BABELRC := $(shell $(FIND_Q) . -mindepth 0 -maxdepth 1 -name ".babelrc*" -print)
LIB_JS_FILES := $(patsubst src/%.js,lib/%.js,$(SRC_JS_FILES))

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	build-babel \

# ------------------------------------------------------------------------------

$(LIB_JS_FILES): lib/%.js: src/%.js $(SRC_JS_FILES) $(BABELRC)
	$(MKDIR) $(shell dirname $@)
	$(BABEL) $< --source-maps --out-file $@


.PHONY: build-babel
build-babel: $(LIB_JS_FILES)
