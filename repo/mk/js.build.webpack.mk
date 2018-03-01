WEBPACK := $(call which,WEBPACK,webpack)

SF_BUILD_TARGETS := \
	$(SF_BUILD_TARGETS) \
	build-webpack \

# ------------------------------------------------------------------------------

.PHONY: build-webpack
build-webpack:
	$(WEBPACK)
