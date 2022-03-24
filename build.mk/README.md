# yplatform/build.mk

**NOTE** this document is **not** about the internals of `make`.
You can read about that in the [GNU make manual](https://www.gnu.org/software/make/manual/make.html),
and many other online resources.

But why `make`???
[Because](https://tech.trivago.com/2019/12/20/makefiles-in-2019-why-they-still-matter/)
[that's](https://bost.ocks.org/mike/make/)
[why](https://www.cs.mtsu.edu/~untch/2170/public/make_utility.pdf)
[over](https://stackoverflow.com/questions/3798562/why-use-make-over-a-shell-script)
[flowed](https://spin.atomicobject.com/2021/03/22/makefiles-vs-package-json-scripts/).

## Standardized targets

As early as [2016](https://blog.capitaines.fr/2016/09/30/standardizing-interfaces-across-projects-with-makefiles/)
someone described why standardization across projects is both possible and important.

No matter which is the primary language,
repositories should at all costs implement the following targets:

* `make help` to show most important targets, and their description
* `make bootstrap` should bootstrap your system with global dependencies
  * example: installing bash/node/python/gnu utils/etc
  * this is not part of the `make deps` step because it would be innefficient
    since global dependecies don't change often, take a long time to install,
    and are also shared to a great extent between our repositories
* `make` should always fetch all dependencies, build and run basic checks
  * `make` should be the same as `make all`
  * `make` should be the same as `make deps build check`
* `make deps` should fetch all dependencies
  * no network connection should be required for upcoming `make build check`
  * dependencies should also be built, where needed
* `make build` should build
  (e.g. compile/transpile/etc)
* `make check` should run basic checks
  (e.g. naming conventions, code style, size of artifacts, run a super quick subset of tests)
* `make test` should run the tests (the whole set)
* `make clean` should remove all known files to be generated,
  while leaving behind files that were manually created.
  This is prone to errors, since the files need to manually listed inside the `Makefile`.
* `make nuke` or `make clobber` should remove all unknown files to git (untracked files).
  Internally it actually creates a stash, so you can safely recover a file.


## Standardized variables

* `V=1` should trigger a verbose build .e.g `V=1 make` or `make V=1`
  * this is perfect for initial debugging


## Development workflow

After `git clone`-ing a repository, a developer should run `make bootstrap` in order to install global dependencies.

After that, a developer should only need to run `make`,
in order to get a fully functional repository, ready for development.

Similarly, after making changes, a developer should only need to run `make` in order to explore their changes.
Or run `make all test` in order to check that tests are green.

**NOTE** the above can be slightly optimized by running the specific tasks alone e.g. `make build` or `make build test`,
but an unexperienced/occasional developer shouldn't be forced to know about these optimizations.

Beyond knowing just `make`, for specific tasks, a developer should know only about `make help`.


## Writing `Makefile`s

In order to follow the standardized targets mentioned above, but also do diminish duplication and errors/corner-cases,
we make use of partial `Makefile`s that when combined cover a great deal of the basic requirements and build steps,
while still allowing for customization/extensibility where needed.

Use the Makefile "puzzle" pieces below by making your main `Makefile` look like this:

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

The high-level collections of pieces are as follows:

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
  * [core.deps.git-hooks.mk](core.deps.git-hooks.mk)
  * [core.build.build-version-files.mk](core.build.build-version-files.mk)
  * [core.check.path.mk](core.check.path.mk)
  * [core.check.path-sensitive.mk](core.check.path-sensitive.mk)
  * [core.check.symlinks.mk](core.check.symlinks.mk)
  * [core.check.tpl.mk](core.check.tpl.mk)
  * [core.check.editorconfig.mk](core.check.editorconfig.mk)
  * [core.check.jsonlint.mk](core.check.jsonlint.mk)
  * [core.check.gitleaks.mk](core.check.gitleaks.mk)
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
* --
* https://www.gnu.org/software/make/manual/make.html
* https://www.integralist.co.uk/posts/building-systems-with-make/
* https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/How_Mozilla_s_build_system_works/Makefiles_-_Best_practices_and_suggestions
* http://web.mit.edu/gnu/doc/html/make_toc.html
