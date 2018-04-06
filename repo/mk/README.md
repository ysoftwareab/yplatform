# support-firecloud/repo/mk

Use these Makefile "puzzle" pieces by making your main/root `Makefile` look like this:

```Makefile
ifeq (,$(wildcard support-firecloud/Makefile))
INSTALL_SUPPORT_FIRECLOUD := $(shell git submodule update --init --recursive support-firecloud)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_SUPPORT_FIRECLOUD
endif
endif

include support-firecloud/repo/mk/generic.common.mk
include support-firecloud/repo/mk/...

# ------------------------------------------------------------------------------

... include here custom variables ...

... include here support-firecloud variables (configuration) ...

# ------------------------------------------------------------------------------

... include here your custom targets ...

```

The pieces **MUST** be included in this order:

* common
* check (not intuitive, but allows for following pieces to alter check vars)
* deps
* build
* test
* publish
* misc

Each "puzzle piece" may have its own usage documentation at the top of the file.

[This is the list of available pieces](./).
