# Style for shell scripts


We follow [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html),
with a few exceptions:

* `#!/usr/bin/env bash` shebang instead of their `#!/bin/bash`.
* free-style function comments instead of their strict pattern.
* `=` as equality comparison instead of their `==`.
* variable names - use all caps, just like for constants/environment variables. Easier to spot.
* filenames - we use a hyphen `-` as the word separator, not an underscore `_`.
* we use "bash strict mode", and thus don't use `$?` to check exit code

Other notable mentions:

* we haven't used constants, via `readonly` or `declare -r`, but it would be ok to
* we haven't used the concept of a `main` function, but it would be a nice addition

## BASH

All shell scripts use `bash`, thus the shebang `#!/usr/bin/env bash`.

Why not just `#!/bin/bash`? In order to allow the user to define which `bash` executable to run.
This also allows the user to use a newer bash than the version built into their OS.


## Strict mode

All shell scripts use `set -euo pipefail`.
Why? Read [the unnoficial bash strict mode](https://github.com/rokmoln/sass-lint-config-firecloud).

Did you read it? Now read it again.

**NOTE** `IFS` is left as is, and thus we don't follow the unnoficial bash strict mode entirely.

This means that optional environment variables need to be referenced as `${OPTIONAL:-}`,
which means "if OPTIONAL is not defined, default to empty string and don't complain about it being undefined".

This also means that each command must succeed or the entire script fails and the execution is terminated.
If you want the script to continue if a command fails, you need to append `|| true` or similar.

Not the least, this also means that pipes will fail if the input command fails
e.g. `false | echo 123` will fail in strict mode, but actually succeed otherwise,
even though `false` returns a exit code 1.


## `if` statements

Due to `set -e`, it becomes natural to write `do_this || do_that`.
At times `do_this` may be just a condition e.g. `test -f /some/file`.
Other times `do_that` may become `do_that && then_some_more`, so you write

```shell
test -f /some/file || {
    do_that
    then_some_more
}
```

Except this is a slightly more controversial (some may say 'less readable') version of

```shell
if ! test -f /some/file; then
    do_that
    then_some_more
fi
```

**BUT** the `if` version is not equivalent, because if the `! test -f /some/file` fails
e.g. `test` is not an available command, then the script is terminated.

Be aware though of the construct `test -f /some/file && do_this || do_that` because `do_that` can be executed
both if `test -f /some/file`, or `do_this` fails.
It is not equivalent to `if test -f /some/file; then do_this; else do_that; fi`.


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
