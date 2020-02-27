# Style for Makefiles

[repo/mk](../repo/mk) and other Makefiles follow a consistent style described bellow.


## Filename

Use `Makefile`, although we write only GNU Makefiles, thus we could use `GNUMakefile`.


## Include `support-firecloud`

``` Makefile
ifeq (,$(wildcard support-firecloud/Makefile))
INSTALL_SUPPORT_FIRECLOUD := $(shell git submodule update --init --recursive support-firecloud)
ifneq (,$(filter undefine,$(.FEATURES)))
undefine INSTALL_SUPPORT_FIRECLOUD
endif
endif

include support-firecloud/repo/mk/...
```

Include `support-firecloud/repo/mk/generic.common.mk`,
or at the very minimum, include `support-firecloud/repo/mk/core.common.mk`.

This will mean that

* a bunch of sane defaults will be set and utility functions will become available.
  * See https://github.com/andreineculau/core.inc.mk/blob/master/core.inc.mk
* a bunch of exe/os/git variables will become available.
  * See https://github.com/andreineculau/core.inc.mk/blob/master/exe.inc.mk
  * See https://github.com/andreineculau/core.inc.mk/blob/master/os.inc.mk
  * See https://github.com/andreineculau/core.inc.mk/blob/master/git.inc.mk
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
* https://github.com/andreineculau/core.inc.mk
* http://blog.jgc.org/2013/02/updated-list-of-my-gnu-make-articles.html
* https://tech.davis-hansson.com/p/make/
