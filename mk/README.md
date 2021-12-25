# yplatform/mk

**NOTE** These are low-level instructions. It is preferrable that you use [build.mk](../build.mk).

Use these Makefile "puzzle" pieces by making your own `Makefile` look like this

```Makefile
ifeq (,$(wildcard yplatform/Makefile))
INSTALL_YP := $(shell git submodule update --init --recursive yplatform)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_YP
endif
endif

include yplatform/mk/common.inc.mk

# ------------------------------------------------------------------------------

... include here custom variables ...

# ------------------------------------------------------------------------------

... include here your custom targets ...

```

The high-level collections of pieces are as follows:

* [common.inc.mk](common.inc.mk)
  * [.inc.mk](.inc.mk)