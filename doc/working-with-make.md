# make

**NOTE** this document is **not** about the internals of `make`.
You can read about that in the [GNU make manual](https://www.gnu.org/software/make/manual/make.html),
and many other online resources.

But why `make`???
[Because](https://tech.trivago.com/2019/12/20/makefiles-in-2019-why-they-still-matter/)
[that's](https://bost.ocks.org/mike/make/)
[why](https://www.cs.mtsu.edu/~untch/2170/public/make_utility.pdf)
[overflowed](https://stackoverflow.com/questions/3798562/why-use-make-over-a-shell-script).

## Standardized targets

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

For more information, see [yplatform/build.mk](../build.mk/README.md) and check out different `Makefile`s
of the [`rokmoln` GitHub repos](https://github.com/rokmoln).


## References

* https://www.gnu.org/software/make/manual/make.html
* https://www.integralist.co.uk/posts/building-systems-with-make/
* https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/How_Mozilla_s_build_system_works/Makefiles_-_Best_practices_and_suggestions
* http://web.mit.edu/gnu/doc/html/make_toc.html
