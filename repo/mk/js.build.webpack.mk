WEBPACK := $(call npm-which,WEBPACK,webpack)
$(foreach VAR,WEBPACK,$(call make-lazy,$(VAR)))

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	build-webpack \

# ------------------------------------------------------------------------------

.PHONY: build-webpack
build-webpack:
	$(WEBPACK)
