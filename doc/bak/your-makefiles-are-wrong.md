Your Makefiles are wrong
========================

[![ads via Carbon](https://cdn4.buysellads.net/uu/1/118028/1659113743-Frame_1.png)](https://srv.carbonads.net/ads/click/x/GTND42JUCYYI653LF6BLYKQNCABIK2JUCE7D4Z3JCYSIK2JLCA7IE53KCWSDC5Q7F67IV237CVAD6KJUCESI623KC6SD52JJCKBDEK3EHJNCLSIZ?segment=placement:davis-hanssoncom;)[How to SSH Properly. Ditch passwords and public & private keys](https://srv.carbonads.net/ads/click/x/GTND42JUCYYI653LF6BLYKQNCABIK2JUCE7D4Z3JCYSIK2JLCA7IE53KCWSDC5Q7F67IV237CVAD6KJUCESI623KC6SD52JJCKBDEK3EHJNCLSIZ?segment=placement:davis-hanssoncom;)[ADS VIA CARBON](http://carbonads.net/?utm_source=davis-hanssoncom&utm_medium=ad_via_link&utm_campaign=in_unit&utm_term=carbon)

DECEMBER 15, 2019 - 9 MINUTE READ

Your Makefiles are full of tabs and errors. An opinionated approach to writing (GNU) Makefiles that I learned from [Ben](https://github.com/benbc) may still be able to salvage them.

An opinionated approach to (GNU) Make
-------------------------------------

This is my second hand account of the approach to Make that I learned from [Ben](https://github.com/benbc). If something is wrong, assume it was lost in translation.

The big things I hope you take away are:

-   The file system is a fundamental part of Make, don't fight it
-   Use sentinel files for targets that do not yield exactly one file
-   Don't use tabs, set -ea -o pipefail, and a few other sensible defaults
-   Use the above as guidelines, not dogma

Because it'll make the examples throughout easier to read, lets start with setting sensible defaults.

Sensible defaults
-----------------

### Don't use tabs

Make leans heavily on the shell, and in the shell spaces matter. Hence, the default behavior in Make of using tabs forces you to mix tabs and spaces, and that leads to readability issues.

Instead, ask make to use `>` as the block character, by adding this at the top of your makefile:

```
ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

```

You really just need the `.RECIPEPREFIX = >` part, but the version check is good since there are a lot of old make binaries floating around.

With this change, a makefile that previously looked like this:

```
hello:
	echo "Hello"
	echo "world"
.PHONY: hello

```

Would look like:

```
hello:
> echo "Hello"
> echo "world"
.PHONY: hello

```

And you will never again pull your hair out because some editor swapped a tab for four spaces and made Make do insane things.

### Always use (a recent) bash

Make uses `/bin/sh` as the default shell. People have `/bin/sh` set up to point to different shell implementations. "Portable shell scripts" is a pipe dream (see what I did there?).

Tell Make "this Makefile is written with Bash as the shell" by adding this to the top of the Makefile:

```
SHELL := bash

```

With a well-known shell targeted, you can confidently skip workarounds for cross-shell compatibility, and use modern bash features.

The key message here, of course, is to choose a specific shell. If you'd rather use ZSH, or Python or Node for that matter, set it to that. Pick a specific language so you can stop targeting a lowest common denominator/

### Use bash strict mode

This holds true any time you use bash, but matters particularly here because without this your build may keep executing even if there was a failure in one of the targets.

There's a good writeup of what these flags do [here](http://redsymbol.net/articles/unofficial-bash-strict-mode/).

Add this to your Makefile:

```
.SHELLFLAGS := -eu -o pipefail -c

```

### Change some Make defaults

`.ONESHELL` ensures each Make recipe is ran as one single shell session, rather than one new shell per line. This both - in my opinion - is more intuitive, and it lets you do things like loops, variable assignments and so on in bash.

`.DELETE_ON_ERROR` does what it says on the box - if a Make rule fails, it's target file is deleted. This ensures the next time you run Make, it'll properly re-run the failed rule, and guards against broken files.

```
MAKEFLAGS += --warn-undefined-variables

```

This does what it says on the tin - if you are referring to Make variables that don't exist, that's probably wrong and it's good to get a warning.

```
MAKEFLAGS += --no-builtin-rules

```

This disables the [bewildering array](https://www.gnu.org/software/make/manual/html_node/Catalogue-of-Rules.html) of built in rules to automatically build Yacc grammars out of your data if you accidentally add the wrong file suffix. Remove magic, don't do things unless I tell you to, Make.

### TL;DR

Use this preamble in your Makefiles:

```
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

```

The file system
---------------

The trigger for this post was a Makefile that was sent to me as the official "this is how you do it" example from a large software company.

Like all the Makefiles I wrote before Ben showed me better, it used Make without regard for its connection to the file system. In this rendition, Make is a tool for writing tab-indented named shell snippets that depend on each other.

These uses would look something like this:

```
test:
> npm run test

deploy: test
> gsutil ..

```

This is bad. Make sees each target ("test" and "deploy") as the output file name of the associated block of code. If the output file exists, Make may decide that it doesn't need to run the code, since the file is already there.

Imagine you stashed some data in a file named `test`. The above Makefile will see that `test` is a file that exists, and that there are no dependencies for the `test` rule. Hence, no need to "rebuild" the test file, and voila you've deployed to prod without running tests.

If you strictly want a target that generates no files, tell Make by saying it is ".PHONY":

```
test:
> npm run test
.PHONY: test  # Make will not look for a file named `test` on the file system

```

### Generating output files

Briefly, then, each Make rule follows a convention like

```
<output-file>: <input file1> <input file 2> <input file n>
> <script to create output-file from input files>

```

Make calls the output the "target", the inputs the "prerequisites" and the script the "recipe". The entire thing is called a "rule".

Say you want to build a docker image for your little Node app. The output file might be a small file that records the image id:

```
out/image-id:
> image_id="example.com/my-app:$$(pwgen -1)"
> docker build --tag="$${image_id}
> echo "$${image_id}" > out/image-id

```

Minor asides:

-   Note the use of $$ instead of $ for bash variables and subshells; Make uses $ for it's own templating variables, $$ escapes it so bash sees a single $.
-   Please ignore the pwgen bit, just need something that generates a random id for the image; much better option here is to hash the image inputs

This Make rule now will generate an output file that contains our image id. Other rules can depend on it, and it's easy for us to use the image id in deploy scripts and so on.

However, *there are problems here*. Our rule specifies no prerequisites, so once the file exists, Make will never rebuild it.

### Specifying inputs

To have make understand when to rebuild our docker image and when not to, we need to tell it what our docker image is built out of. When those prerequisites change, it needs to rebuild the image.

```
out/image-id: src/main.js src/views.js
> image_id="example.com/my-app:$$(pwgen -1)"
> docker build --tag="$${image_id}
> echo "$${image_id}" > out/image-id

```

Now, if you made a change to `main.js` or `views.js`, Make will rebuild the image. However, maintaining a list of all the source files is a massive pain - and of course unnecessary, the file system already knows this information, so lets just ask it.

Like mentioned earlier, Make recognizes $-prefixed variables and commands. One such command is `shell`, which lets us run a shell command and have its output substituted into our Makefile.

To find all the source files, you might do something like: `find src/ -type f`. Simply replace the manual listing of prerequisite files with this.

```
out/image-id: $(shell find src -type f)
> image_id="example.com/my-app:$$(pwgen -1)"
> docker build --tag="$${image_id}
> echo "$${image_id}" > out/image-id

```

Sentinel files
--------------

It is possible to have one rule generate multiple files. For instance, the Webpack webapp bundler might yield lots of output files.

```
index.html: $(shell find src -type f)
> node run webpack ..

```

Here, Make will only rebuild the target if `index.html` is older than either of the dependencies. What if some other file outputted by webpack is much older? You can write a target with a templated output to have Make handle this. If you hate yourself.

This becomes particularly insane once you start running Make in parallel.

A better option is to have rules that yield lots of files have a "sentinel" output. A single file that you know Make will look at to tell if a rebuild is needed:

```
out/.packed.sentinel: $(shell find src -type f)
> node run webpack ..
> touch out/.packed.sentinel

```

On Make magic variables
-----------------------

Make has a bunch of cryptic magic variables that refer to things like the targets and prerequisites of rules. I mostly think these should be avoided, because they are hard to read.

However, for the sentinel file pattern, the magic variable `$(@D)`, which refers to the directory the target should go in, and `$@`, which refers to the target, are common enough that you quickly learn to recognize what they mean:

```
out/.packed.sentinel: $(shell find src -type f)
> mkdir -p $(@D) # expands to `mkdir -p out`
> node run webpack ..
> touch $@  # expands to `touch out/.packed.sentinel`

```

Putting it all together
-----------------------

In the end, for a Makefile to build a Node app and package it into a docker image, you might do something like:

```
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

# Default - top level rule is what gets ran when you run just `make`
build: out/image-id
.PHONY: build

# Clean up the output directories; since all the sentinel files go under tmp, this will cause everything to get rebuilt
clean:
> rm -rf tmp
> rm -rf out
.PHONY: clean

# Tests - re-ran if any file under src has been changed since tmp/.tests-passed.sentinel was last touched
tmp/.tests-passed.sentinel: $(shell find src -type f)
> mkdir -p $(@D)
> node run test
> touch $@

# Webpack - re-built if the tests have been rebuilt (and so, by proxy, whenever the source files have changed)
tmp/.packed.sentinel: tmp/.tests-passed.sentinel
> mkdir -p $(@D)
> webpack ..
> touch $@

# Docker image - re-built if the webpack output has been rebuilt
out/image-id: tmp/.packed.sentinel
> mkdir -p $(@D)
> image_id="example.com/my-app:$$(pwgen -1)"
> docker build --tag="$${image_id}
> echo "$${image_id}" > out/image-id

```

This is not dogma
-----------------

One of the virtues of Make, to me, is that it is pragmatic. Counterintuitively, I think part of the reason Make has managed to maintain simplicity is precisely because it has allowed some hacks to accumulate in the tool itself.

The alternative is to expand the model to be more generic, to incorporate new concepts, making the core model more complex.

In the end, the hacks have allowed the exceptional beauty of the core model - a way to describe file construction pipelines tightly connected with the file system tree - to remain simple.