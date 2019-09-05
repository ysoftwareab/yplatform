# support-firecloud/repo/mk

Use these Makefile "puzzle" pieces by making your main `Makefile` look like this:

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
* deps
* build
* check
* test
* release
* misc

**NOTE** All are split into:

* docs
* includes
* variables
* targets

The high-level colletions of pieces are as follows:

* [core.common.mk](core.common.mk) - the "bare minimum" for generic repositories
  * [core.clean.mk](core.clean.mk)
  * [core.deps.mk](core.deps.mk)
  * [core.build.mk](core.build.mk)
  * [core.check.mk](core.check.mk)
  * [core.test.mk](core.test.mk)
  * [core.vendor.mk](core.vendor.mk)
* [generic.common.mk](generic.common.mk) - [core.common.mk](core.common.mk) + the "must have" for generic repositories
  * [core.build-version-file.mk](core.build-version-file.mk)
  * [core.check.eclint.mk](core.check.eclint.mk)
  * [core.check.jsonlint.mk](core.check.jsonlint.mk)
  * [core.check.path.mk](core.check.path.mk)
  * [core.deps.git-hook-pre-push.mk](core.deps.git-hook-pre-push.mk)
  * [core.misc.bootstrap.mk](core.misc.bootstrap.mk)
  * [core.misc.sf-update.mk](core.misc.sf-update.mk)
  * [core.misc.snapshot.mk](core.misc.snapshot.mk)
  * [core.misc.transcrypt.mk](core.misc.transcrypt.mk)
  * [core.misc.version.mk](core.misc.version.mk)
  * [core.release.mk](core.release.mk)
* [js.common.mk](js.common.mk) - [generic.common.mk](generic.common.mk) + the "must have" for JavaScript repositories
  * [js.deps.npm.mk](js.deps.npm.mk)
* [node.common.mk](node.common.mk) - [js.common.mk](js.common.mk) + the "must have" for NodeJS repositories
  * [js.build.babel.mk](js.build.babel.mk)
* [py.common.mk](py.common.mk) - [generic.common.mk](generic.common.mk) + the "must have" for Python repositories
  * [py.deps.pipenv.mk](py.deps.pipenv.mk)

**NOTE** It is only `*.common.mk` makefiles that can `include`. All others are atomic.

Addon pieces by type of repository:
* generic
  * [core.misc.merge-upstream.mk](core.misc.merge-upstream.mk)
  * [core.misc.source-const-inc.mk](core.misc.source-const-inc.mk)
  * [core.release.npg.mk](core.release.npg.mk)
  * [core.release.tag.mk](core.release.tag.mk)
  * [env.common.mk](env.common.mk) (FIXME)
    * [env.promote-tag-to-env-branch.mk](env.promote-tag-to-env-branch.mk)
    * [env.teardown-env.mk](env.teardown-env.mk)
* JavaScript/NodeJS
  * [js.build.d.ts.mk](js.build.d.ts.mk)
  * [js.build.webpack.mk](js.build.webpack.mk)
  * [js.check.d.ts.mk](js.check.d.ts.mk)
  * [js.check.eslint.mk](js.check.eslint.mk)
  * [js.check.sasslint.mk](js.check.sasslint.mk)
  * [js.deps.private.mk](js.deps.private.mk)
  * [js.test.jest.mk](js.test.jest.mk)
* Python
  * [py.check.flake.mk](py.check.flake.mk)

For a full list of available pieces [click here](./).
