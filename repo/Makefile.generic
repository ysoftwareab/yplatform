ifeq (,$(wildcard yplatform/Makefile))
INSTALL_YP := $(shell git submodule update --init --recursive yplatform)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_YP
endif
endif

include yplatform/build.mk/generic.common.mk

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
