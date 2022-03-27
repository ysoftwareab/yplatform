# Style for shell scripts


We follow [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html),
with a few exceptions:

* `#!/usr/bin/env bash` shebang instead of their `#!/bin/bash`.
* free-style function comments instead of their strict pattern.
* `=` as equality comparison instead of their `==`.
* variable names - use all caps, just like for constants/environment variables. Easier to spot.
* filenames - we use a hyphen `-` as the word separator, not an underscore `_`.
* we use ["strict mode"](#strict-mode), and thus don't use `$?` to check exit code

Other notable mentions:

* we haven't used constants, via `readonly` or `declare -r`, but it would be ok to.
* we haven't used widely the concept of a `main` function, but it would be a nice addition.
  Then scripts can call `[[ "$0" != "${BASH_SOURCE[0]}" ]] || main "$@"` at the bottom.
* although the keyword `function` is deprecated, we use it because you it enhances the search for function definitions.
  From Google's Shell Style Guide:
  "The function keyword is extraneous when () is present after the function name, but enhances quick identification of functions."

We aim to write robust/defensive shell scripts.


## Include `yplatform`

```bash
#!/usr/bin/env bash
set -euo pipefail

YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../path/to/yplatform" && pwd)"
source ${YP_DIR}/sh/common.inc.sh
```

This will mean that

* a bunch of sane defaults will be set and utility functions will become available.
  * See [sh](../sh)
* a bunch of exe/os/git variables will become available.
  * See [sh/exe.inc.sh](../sh/exe.inc.sh)
  * See [sh/os.inc.sh](../sh/os.inc.sh)
  * See [sh/git.inc.sh](../sh/git.inc.sh)


## GNU Bash

All shell scripts use `bash`, thus the shebang `#!/usr/bin/env bash`.

Why not just `#!/bin/bash`? In order to allow the user to define which `bash` executable to run.
This also allows the user to use a newer bash than the version built into their OS.

Why `bash`? Because it is ["the JavaScript of systems programming"](https://github.com/progrium/bashstyle/blob/master/README.md):
it's everywhere, it's neutral, it's made to be glue.

Glue what? [All sorts of command line goodies.](https://github.com/jlevy/the-art-of-command-line/blob/master/README.md)

Interested in pure-bash alternatives to common scenarios?
Check the [Pure Bash Bible](https://github.com/dylanaraps/pure-bash-bible/blob/master/README.md).


## Strict mode

All shell scripts use `set -euo pipefail`.
Why? Read [the unofficial bash strict mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/).

Did you read it? Now read it again.

**NOTE** `IFS` is left as is, and thus we don't follow the unnoficial bash strict mode entirely.

This means that optional environment variables need to be referenced as `${OPTIONAL:-}`,
which means "if OPTIONAL is not defined, default to empty string and don't complain about it being undefined".

This also means that each command must succeed or the entire script fails and the execution is terminated.
If you want the script to continue if a command fails, you need to append `|| true` or similar.

Not the least, this also means that pipes will fail if the input command fails
e.g. `false | echo 123` will fail in strict mode, but actually succeed otherwise,
even though `false` returns a exit code 1.


## Idempotent commands

(Strive for resilient shell scripts by writing idempotent commands.)[https://arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts/]


## `if` statements

Due to `set -e`, it becomes natural to write `do_this || do_that`.
At times `do_this` may be just a condition e.g. `test -f /some/file`.
Other times `do_that` may become `do_that && then_some_more`, so you write

```shell
[[ -f /some/file ]] || {
    do_that
    then_some_more
}
```

The above is a slightly more controversial (some may say 'less readable') version of

```shell
if [[ ! -f /some/file ]]; then
    do_that
    then_some_more
fi
```

Be aware though of the construct `[[ -f /some/file ]] && do_this || do_that` because `do_that` can be executed
both if `[[ -f /some/file ]]`, or `do_this` fails.
It is not equivalent to `if [[ -f /some/file ]]; then do_this; else do_that; fi`.


## Double brackets `[[ ]]`

You can read about test constructs [here](https://www.tldp.org/LDP/abs/html/testconstructs.html),
which reads

> With version 2.02, Bash introduced the [[ ... ]] extended test command,
> which performs comparisons in a manner more familiar to programmers from other languages.

From https://www.tldp.org/LDP/abs/html/testconstructs.html#DBLBRACKETS :

* No filename expansion or word splitting takes place between `[[ ]]`,
  but there is parameter expansion and command substitution.

* the `&&`, `||`, `<`, and `>` operators work within a `[[ ]]` test,
despite giving an error within a `[ ]` construct.


## References

* https://google.github.io/styleguide/shellguide.html
* http://redsymbol.net/articles/unofficial-bash-strict-mode/
* https://arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts/
* https://github.com/dylanaraps/pure-bash-bible/blob/master/README.md
* https://github.com/progrium/bashstyle/blob/master/README.md
* https://www.davidpashley.com/articles/writing-robust-shell-scripts/
* https://github.com/jlevy/the-art-of-command-line/blob/master/README.md
*
* Additional that might go astray from our own style:
* https://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/
* http://www.pixelbeat.org/programming/shell_script_mistakes.html
* Wiki https://wiki.bash-hackers.org/start
* Wiki http://mywiki.wooledge.org/BashPitfalls
