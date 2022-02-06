WEBPACK := $(call npm-which,WEBPACK,webpack)
$(foreach VAR,WEBPACK,$(call make-lazy-once,$(VAR)))

YP_BUILD_TARGETS += \
	build-webpack \

# ------------------------------------------------------------------------------

.PHONY: build-webpack
build-webpack:
	$(WEBPACK)
