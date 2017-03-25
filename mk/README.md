# core.inc.mk

I make (pun) a lot of things, and I want to keep it DRY.

The `docs` folder has some tips and tricks as well.

# Usage

I would have this repository as a submodule e.g. as a `core.inc.mk` folder,
and then reference it at the top of the real `Makefile`:

```make
include core.inc.mk/Makefile
```

Similarly, if I just want bits and pieces of this:

```make
include core.inc.mk/core.inc.mk
include core.inc.mk/target.help.inc.mk
```

# License

[Unlicense](LICENSE).
