SRC_D_TS_FILES := $(shell $(FIND_Q) src -type f -name "*.d.ts" -print)
LIB_D_TS_FILES := $(patsubst src/%.d.ts,lib/%.d.ts,$(SRC_D_TS_FILES))

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	build-d-ts

# ------------------------------------------------------------------------------

$(LIB_D_TS_FILES): lib/%.d.ts: src/%.d.ts $(SRC_D_TS_FILES)
	$(MKDIR) $(shell dirname $@)
	cp $< $@

.PHONY: build-d-ts
build-d-ts: $(LIB_D_TS_FILES)
