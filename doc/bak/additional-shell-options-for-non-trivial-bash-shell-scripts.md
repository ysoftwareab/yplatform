Additional shell options for non-trivial (Bash) shell scripts
=============================================================

May 13, 2020 - 

Tags: [debugging](https://saveriomiroddi.github.io/tag/debugging/), [linux](https://saveriomiroddi.github.io/tag/linux/), [shell_scripting](https://saveriomiroddi.github.io/tag/shell-scripting/), [sysadmin](https://saveriomiroddi.github.io/tag/sysadmin/)

For a variety of reasons, writing (Bash) shell scripts requires lots of care. When writing non-trivial shell scripts, it's crucial to take precautions; shell options are part of this practice.

Typically, three shell options are suggested: `errexit`, `nounset` and `pipefail`, and occasionally, `noglob`.

However, there are other ones that developers will find important in this context: `errtrace` and `inherit_errexit`; in this article, I'll explain them.

Content:

-   [A recap of the common shell options for solid programming](https://saveriomiroddi.github.io/Additional-shell-options-for-non-trivial-bash-shell-scripts#a-recap-of-the-common-shell-options-for-solid-programming)
-   [`errtrace` (`-E`)](https://saveriomiroddi.github.io/Additional-shell-options-for-non-trivial-bash-shell-scripts#errtrace--e)
-   [`inherit_errexit`](https://saveriomiroddi.github.io/Additional-shell-options-for-non-trivial-bash-shell-scripts#inherit_errexit)
-   [Conclusion](https://saveriomiroddi.github.io/Additional-shell-options-for-non-trivial-bash-shell-scripts#conclusion)

A recap of the common shell options for solid programming
---------------------------------------------------------

Typically, three shell options are suggested for solid programming.

**`errexit` (`-e`)**: exit in case of error. This is important, and the benefits evident.

**`nounset` (`-u`)**: return an error if an unset variable is used. This is a bit tricky, because it requires overhead: the developer will need to use constructs like `${1:-}`, in order to initialize variables that are not set, even if it's expected for them to be unset. All in all though, when working on non-trivial scripts, it's overall productive (in my opinion) to be sure that one doesn't accidentally use unset variables.

**`pipefail`**: return the exit status of the first failing command in a pipeline (`cmd1 | cmd2 | cmd3`), rather than the last one; in other words, abort a pipeline with an error, if any command fails. This is, again, a no-brainer (although, be careful when using `grep`!)

Another relevant shell option is **`noglob` (`-f`)**, which disables filename expansion. My argument against its usefulness is that a correctly quoted script won't suffer from unintentional expansion. On the other hand, developers who don't apply rigorous quoting, will certainly find it useful.

`errtrace` (`-E`)
-----------------

On non-trivial scripts, signals trapping is a useful functionality.

A very simple example is printing debugging variables on exit:

```
cat > /tmp/test_errtrace.sh << 'SHELL'
set -o errexit

var=foo

function print_variables {
  echo "Debug: \$var= $var"
}

function trap_errors {
  trap print_variables ERR
}

function main {
  echo "The script starts"
  echo "Error coming; debug routine will kick in!"
  false
  echo "The script ends"
}

trap_errors
main
SHELL

```

Let's try it:

```
$ bash /tmp/test_errtrace.sh
The script starts
Error coming; debug routine will kick in!

```

Ouch 😳. Why the error is not caught?

The problem is: by default, in the context of functions, `ERR` trapping is not inherited.

So now, we know we need to employ another shell option, `errtrace` (`-E`):

```
$ sed -ie '1aset -o errtrace' /tmp/test_errtrace.sh
$ bash /tmp/test_errtrace.sh
The script starts
Error coming; debug routine will kick in!
Debug: $var= foo

```

Now we're talking! 😇

`inherit_errexit`
-----------------

Another construct that one typically uses on non-trivial scripts, is command substitution (`$(<command>)`).

Again, let's see an example script:

```
cat > /tmp/test_inherit_errexit.sh << 'SHELL'
set -o errexit

function processed_list_directory {
  local directory_listing

  directory_listing=$(ls -l "$1" 2> /dev/null)

  if [[ $directory_listing == "total 0" ]]; then
    echo "(empty directory)"
  else
    echo "$directory_listing"
  fi
}

function main {
  local processed_listing_tmp
  local processed_listing_foo

  processed_listing_tmp=$(processed_list_directory /tmp)

  echo "Listing 1: $processed_listing_tmp"
  echo

  processed_listing_foo=$(processed_list_directory /foo)

  echo "Listing 2: $processed_listing_foo"
}

main
SHELL

```

The structure of this script is realistic: we have a function that performs some commands, whose output is assigned to a variable.

Since we've set the `errexit` shell option, we expect the script to blow up when performing the second processed listing. Let's see:

```
$ bash /tmp/test_inherit_errexit.sh
Listing 1: total 288
-rw-rw-r-- 1 saverio saverio    214 Mai 13 08:59 pizza.sh
# other files

Listing 2:

```

Ouch again! The script didn't exit. What's happening?

Well, the problem is that in Bash, the `errexit` option is not inherited by shells spawned by command substitution. This is of course a significant problem.

Fortunately, on Bash 4.4+, there is a shell option to set this intended behavior, `inherit_errexit`:

```
$ sed -ie '1ishopt -s inherit_errexit' /tmp/test_inherit_errexit.sh
$ bash /tmp/test_inherit_errexit.sh
Listing 1: total 288
-rw-rw-r-- 1 saverio saverio    214 Mai 13 08:59 pizza.sh
# other files

```

The script now exited as soon as `processed_list_directory()` failed.

Conclusion
----------

Now we know that, as part of solid shell script development practices, we need to set (at least) five shell options.

The Bash learning process is somewhat a cycle of pulling one's hair, then finding there is a language quirk that needs to be known and addressed.

However, all in all, there is no doubt that Bash is by far the best of all the glue languages (the other ones being: there aren't).
