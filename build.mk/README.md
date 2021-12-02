# yplatform/build.mk

Use these Makefile "puzzle" pieces by making your main `Makefile` look like this:

```Makefile
ifeq (,$(wildcard yplatform/Makefile))
INSTALL_YP := $(shell git submodule update --init --recursive yplatform)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_YP
endif
endif

include yplatform/build.mk/generic.common.mk
include yplatform/build.mk/...

# ------------------------------------------------------------------------------

... include here custom EXE variables, which call which/npm-which ...

... include here custom variables ...

... include here yplatform variables (configuration) ...

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

* [core.common.mk](core.common.mk) - for bare minimum repositories
  * [core.vendor.mk](core.vendor.mk)
  * [core.clean.mk](core.clean.mk)
  * [core.deps.mk](core.deps.mk)
  * [core.build.mk](core.build.mk)
  * [core.check.mk](core.check.mk)
  * [core.shell.mk](core.shell.mk)
  * [core.test.mk](core.test.mk)
  * [core.node.mk](core.node.mk)
  * [core.archive.mk](core.archive.mk)
  * [core.ci.mk](core.ci.mk)
* [generic.common.mk](generic.common.mk) - for generic repositories
  * [core.common.mk](core.common.mk)
  * [core.deps.git-hook-pre-push.mk](core.deps.git-hook-pre-push.mk)
  * [core.build.build-version-files.mk](core.build.build-version-files.mk)
  * [core.check.path.mk](core.check.path.mk)
  * [core.check.path.mk](core.check.path-sensitive.mk)
  * [core.check.path.mk](core.check.symlinks.mk)
  * [core.check.tpl.mk](core.check.tpl.mk)
  * [core.check.editorconfig.mk](core.check.editorconfig.mk)
  * [core.check.jsonlint.mk](core.check.jsonlint.mk)
  * [core.misc.promote.mk](core.misc.promote.mk)
  * [core.misc.version.mk](core.misc.version.mk)
  * [core.misc.release.mk](core.misc.release.mk)
  * [core.misc.docker-ci.mk](core.misc.docker-ci.mk)
  * [core.misc.bootstrap.mk](core.misc.bootstrap.mk)
  * [core.misc.yp-update.mk](core.misc.yp-update.mk)
  * [core.misc.snapshot.mk](core.misc.snapshot.mk)
  * [core.misc.transcrypt.mk](core.misc.transcrypt.mk)

Miscelaneous "must haves" require [generic.common.mk](generic.common.mk):
* [js.common.mk](js.common.mk) - for generic JavaScript repositories
  * [js.deps.npm.mk](js.deps.npm.mk)
* [node.common.mk](node.common.mk) - for NodeJS JavaScript repositories
  * [js.build.babel.mk](js.build.babel.mk)
* [py.common.mk](py.common.mk) - for Python repositories
  * [py.deps.pipenv.mk](py.deps.pipenv.mk)

Addon pieces by type of repository:
* generic
  * [core.misc.merge-upstream.mk](core.misc.merge-upstream.mk)
  * [core.misc.source-const-inc.mk](core.misc.source-const-inc.mk)
  * [core.release.npg.mk](core.release.npg.mk)
  * [core.release.tag.mk](core.release.tag.mk)
  * [env.common.mk](env.common.mk)
    * [env.promote.mk](env.promote.mk)
    * [env.teardown.mk](env.teardown.mk)
* JavaScript/NodeJS
  * [js.deps.private.mk](js.deps.private.mk)
  * [js.deps.yarn.mk](js.deps.yarn.mk)
  * [js.build.cp-dts.mk](js.build.cp-dts.mk)
  * [js.build.webpack.mk](js.build.webpack.mk)
  * [js.check.d.ts.mk](js.check.d.ts.mk)
  * [js.check.eslint.mk](js.check.eslint.mk)
  * [js.check.sasslint.mk](js.check.sasslint.mk)
  * [js.test.jest.mk](js.test.jest.mk)
* Python
  * [py.check.flake.mk](py.check.flake.mk)

For a full list of available pieces [click here](./).


# References

* http://blog.jgc.org/2013/02/updated-list-of-my-gnu-make-articles.html
* https://tech.davis-hansson.com/p/make/
