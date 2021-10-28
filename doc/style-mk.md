# Style for Makefiles

[build.mk](../build.mk) and other Makefiles follow a consistent style described bellow.


## Filename

Use `Makefile`, although we write only GNU Makefiles, thus we could use `GNUMakefile`.


## Include `yplatform`

``` Makefile
ifeq (,$(wildcard yplatform/Makefile))
INSTALL_SUPPORT_FIRECLOUD := $(shell git submodule update --init --recursive yplatform)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_SUPPORT_FIRECLOUD
endif
endif

include yplatform/build.mk/...
```

Include `yplatform/build.mk/generic.common.mk`,
or at the very minimum, include `yplatform/build.mk/core.common.mk`.

This will mean that

* a bunch of sane defaults will be set and utility functions will become available.
  * See [mk](../mk)
* a bunch of exe/os/git variables will become available.
  * See [mk/exe.inc.mk](../mk/exe.inc.mk)
  * See [mk/os.inc.mk](../mk/os.inc.mk)
  * See [mk/git.inc.mk](../mk/git.inc.mk)
* a bunch of sane target patterns will become available.
  * `make` = `make all` = `make deps build check`
  * `make clean`, `make nuke`
  * `make deps`
  * `make build`
  * `make check`
  * `make test`
  * `make help`
  * etc.


## Target naming

TODO


## Assignments

TODO


## References

* https://www.gnu.org/prep/standards/html_node/Makefile-Conventions.html
* http://clarkgrubb.com/makefile-style-guide
* http://blog.jgc.org/2013/02/updated-list-of-my-gnu-make-articles.html
* https://tech.davis-hansson.com/p/make/
