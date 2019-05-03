BABEL = $(call which,BABEL,babel)
BABEL_NODE = $(call which,BABEL_NODE,babel-node)
$(foreach VAR,BABEL BABEL_NODE,$(call make-lazy,$(VAR)))

BABELRC := $(shell $(FIND_Q_NOSYM) . -mindepth 0 -maxdepth 1 -name ".babelrc*" -print)
LIB_JS_FILES := $(patsubst src/%.js,lib/%.js,$(SRC_JS_FILES))

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	$(LIB_JS_FILES) \

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	build-babel \

BABEL_ARGS := \
	--source-maps

# ------------------------------------------------------------------------------

$(LIB_JS_FILES): lib/%.js: src/%.js $(SRC_JS_FILES) $(BABELRC)
	$(MKDIR) $(shell dirname $@)
	$(BABEL) $< $(BABEL_ARGS) --out-file $@


.PHONY: build-babel
build-babel: $(LIB_JS_FILES)
