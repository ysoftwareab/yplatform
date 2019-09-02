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

* common (e.g. generic.common.mk)
* check
  * not intuitive to have 'check' so early since it runs after 'build',
    but allows for upcoming pieces to alter 'check' vars
* deps
* build
* test
* publish
* misc

[This is the full list of available pieces](./).

Each "puzzle piece" may have its own usage documentation at the top of the file.

The high-level hierarchy of pieces is as follows:

* core.common.mk
  * core.bootstrap.mk
  * core.clean.mk
  * core.deps.mk
  * core.build.mk
  * core.check.mk
  * core.test.mk
  * core.sf-update.mk
* generic.common.mk
  * core.common.mk
  * core.vendor.transcrypt.mk
  * core.deps.git-hook-pre-push.mk
  * core.build-version-file.mk
  * core.check.path.mk
  * core.check.eclint.mk
  * core.check.jsonlint.mk
  * core.misc.snapshot.mk
* js.common.mk
  * generic.common.mk
  * js.deps.npm.mk
  * js.misc.version.mk
  * js.misc.release.mk
* js.common.node.mk
  * js.common.mk
  * js.build.babel.mk
* py.common.mk
  * generic.common.mk
  * py.deps.pipenv.mk
