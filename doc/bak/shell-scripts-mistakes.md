I've written a few [shell scripts](http://www.pixelbeat.org/scripts/) in my time and have read many more, and I see the same issues cropping up again and again (unfortunately even in my own scripts sometimes).

While there are lots of shell programming [pitfalls](http://mywiki.wooledge.org/BashPitfalls), at least the interpreter will tell you immediately about them. The mistakes I describe below, generally mean that your script will run fine now, but if the data changes or you move your script to another system, then you may have problems.

I think some of the reason shell scripts tend to have lots of issues is that commonly one doesn't learn shell scripting like "traditional" programming languages. Instead scripts tend to evolve from existing interactive command line use, or are based on existing scripts which themselves have propagated the limitations of ancient shell script interpreters.

It's definitely worth spending the relatively small amount of time required to [learn](http://tldp.org/LDP/abs/html/) the shell script language correctly, if one uses linux/BSD/Mac OS X desktops or servers, where it is commonly used.

Inappropriate use
-----------------

shell is the main *domain specific language* designed to manipulate the UNIX abstractions for data and logic, i.e. [files and processes](http://www.pixelbeat.org/talks/linux_and_python/page12.html). So as well as being useful at the command line, its use permeates any UNIX system. Correspondingly, please be wary of writing scripts that deviate from these abstractions, and have significant data manipulation in the shell process itself. While flexible, shell is not designed as a general purpose language and becomes unwieldly when not leveraging the various [UNIX tools](http://www.pixelbeat.org/docs/unix_commands/) effectively. A good knowlegde of the various UNIX tools goes hand in hand with effective shell programming.

Stylistic issues
----------------

First I'll mention some ways to clean up shell scripts without changing their functionality. Note I use a shortcut form of the conditional operator below (and in my shell scripts), when doing *simple* conditional operations, as it's much more concise. So I use [ "$var" = "find" ] && echo "found" instead of the equivalent:

if [ "$var" = "find" ]; then
  echo "found"
fi

It's better to use the longer *"if"* form though, if running multiple commands based on the condition, because if you use `set -e` in your script to exit immediately upon unexpected command failure, then using [ "$var" ] && cmd1 && cmd2 && last would only exit if *"last"* fails.

### [ x"$var" = x"find" ] && echo found

The use of x"$var" was required in case var is "" or "-hyphen". Thinking about this for a moment should indicate that the shell can handle both of these cases unambiguously, and if it doesn't it's a bug. This bug was probably fixed about 20 years ago, so stop propagating this nonsense please! Shell doesn't have the cleanest syntax to start with, so polluting it with stuff like this is horrible.

### [ ! -z "$var" ] && echo "var not empty"

This is a double negative, and is very prevalent in shell scripts for some reason.\
Just test the string directly like [ "$var" ] && echo "var not empty"

### [ "$var" ] || var="value"

Setting a variable iff it's not previously set is a common idiom and can be more succinctly expressed like\
: ${var="value"}. Note if you want to set a variable if it's empty or unset use : ${var**:**="value"}.\
These are portable to the vast majority of shells.

### [ "$var" ] && var="foo-$var" || var="foo"

Similarly to the previous case where we avoid explicit conditionals in shell logic, one can leverage conditional shell parameter expansion to handle the very common requirement of building up variant file names etc. like:

variant=bar
var="foo${variant:+-}$variant"

### redundant use of $?

For example:

pidof program
if [ $? = 1 ]; then
  echo "program not found"
fi

Note this is not just stylistic actually. Consider what happens if `pidof` returns 2.\
Instead just test the exit status of the process directly as in these examples:

if ! pidof program; then
  echo "program not found"
fi

if grep -qF "string" file; then
  echo 'file contains "string"'
fi

Be careful though when checking negative returns, as you generally get a negative return for any failure, like I/O error etc. For example if using grep to check there is **no** match, then using $? is not redundant:

grep -q 'regex' FILE; local st=$?
if [ $st = 1 ]; then
  echo no-match
fi

### needless shell logic

We'll expand on this below, but we should do as little in shell as possible, over its domain of connecting process to files. For example the following common shell idiom of testing for files and directories can often be pushed into the programs themselves. I.E. instead of:

[ ! -d "$dir" ] && mkdir "$dir"
[ -f "$file" ] && rm "$file"

do:

mkdir -p "$dir" #also creates a hierarchy for you
rm -f "$file" #also never prompts

Note also [Google's shell style guide](https://google.github.io/styleguide/shell.xml) which as per other google style guides has very sensible advice.

Robustness
----------

Aaron Maxwell wrote up a good summary of settings and consequences for an [unofficial strict mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/) for **bash** which is worth considering for your bash scripts at least. Here I discuss more general techniques appropriate for most shell scripts.

### globbing

In the example below to count the lines in each file, there is a common mistake.

for file in `ls *`; do
  wc -l $file
done

Perhaps the idiom above stems from a common system where the shell does not do globbing, but in any case it's neither scalable or robust. It's not robust because it doesn't handle spaces in file names as word splitting is done. Also it redundantly starts an ls process to list the files. Also on some systems this form can overflow static command line buffers when there are many files. Shell script is a language designed to operate on files so it has this functionality built in!

for file in *; do
  wc -l -- "$file"
done

Notice how we just use the '*' directly which as well as not starting the redundant `ls` process, doesn't do word splitting on file names containing spaces. Also notice the added '--' option, to indicate to wc to stop option processing and thus be immune to file names starting with '-'. Note this still is slow, as we use shell looping and start a `wc` process per file, so we'll come back to this example in the performance section below.

### quoting

Shell quoting is a complicated area whose subtleties are often overlooked, and this is compounded when combined with the fact that file names can contain almost any character. The following quoting guidelines come from David A. Wheeler's excellent article on[Filenames and Pathnames in Shell](http://www.dwheeler.com/essays/filenames-in-shell.html), which is worth reading in its entirety:

> 1.  Double-quote all variable references and command substitutions unless you are certain they can only contain alphanumeric characters or you have specially prepared things (i.e., use "$variable" instead of $variable). In particular, you should practically always put $@ inside double-quotes; POSIX defines this to be special (it expands into the positional parameters as separate fields even though it is inside double-quotes).
> 2.  Set IFS to just newline and tab, if you can, to reduce the risk of mishandling filenames with spaces. Use newline or tab to separate options stored in a single variable. Set IFS with IFS="$(printf '\n\t')"
> 3.  Prefix all pathname globs so they cannot expand to begin with "-". In particular, never start a glob with "?" or "*" (such as "*.pdf"); always prepend globs with something (like "./") that cannot expand to a dash. So never use a pattern like "*.pdf"; use "./*.pdf" instead.
> 4.  Check if a pathname begins with "-" when accepting pathnames, and then prepend "./" if it does.
> 5.  Be careful about displaying or storing pathnames, since they can include newlines, tabs, terminal control escape sequences, non-UTF-8 characters (or characters not in your locale), and so on. You can strip out control characters and non-UTF-8 characters before display using printf '%s' "$file" | LC_ALL=POSIX tr -d '[:cntrl:]' | iconv -cs -f UTF-8 -t UTF-8
> 6.  Do not depend on always using "--" between options and pathnames as the primary countermeasure against filenames beginning with "-". You have to do it with every command for this to work, but people will not use it consistently (they never have), and many programs (including echo) do not support "--". Feel free to use "--" between options and pathnames, but only as an additional optional protective measure.
> 7.  Use a template that is known to work correctly (see paper).
> 8.  Use a tool like shellcheck to find problems you missed.

Related to this is recently [POSIX added support for $'...'](http://austingroupbugs.net/view.php?id=249) quoting format to easily and unambiguously specify any string, and the GNU ls(1) command since coreutils v8.25 takes advantage of that to display file names in an unambiguous and safe to paste back manner. Consider for example if a bad actor placed a file called **$'\055\162\146 \057h\157m\145'** in /tmp for example, and naïvely one tried to remove it by pasting (as output by older ls commands) to an rm command in the same terminal session, in which case it would remove all /home directories. With newer GNU ls, the file name is always quoted so that it can be safely pasted back to other commands, which is useful to avoid malicious file names or just problematic file names that can not be referenced without appropriate quoting.

### stopping automatically on error

Often don't want a script to proceed if some commands fail. Checking the status of each command though can become very messy and error prone. One can instead execute set -e at the top of the script, which usually just works as expected, terminating the script when any command fails (that is not already part of a conditional etc.).

### cleaning up temp files

One should always try to avoid temp files for performance/maintainability reasons, and instead use pipes if at all possible to pass data between processes. Temporary files can be slow as they're usually written to disk, and also you must handle cleaning them up when your script exits, possibly in unexpected ways. The general method for cleaning up temp files if you really do need them is to use traps as follows:

#!/bin/sh

tf=/tmp/tf.$$

cleanup() {
  rm -f $tf
}

trap "cleanup" EXIT

touch $tf
echo "$tf created"
sleep 10 #Can Ctrl-C and temp file will still be removed
#temp file auto removed on exit

### echoing errors

If you just echo "Error occurred" then you will not be able to pipe or redirect any normal output from your script independently. It's much more standard and maintainable to output errors to stderr like echo "Error occurred" >&2. Note you can echo multiple lines together as in the following example:

echo  "\
Usage: $(basename $0) option1
more info
even more" >&2

Portability
-----------

There are two aspects to portability really for shell scripts. There's the shell language itself, and also the various tools being called by the script. We'll just consider the former here. To support really old implementations of shell script then one can test with the[heirloom shell](http://heirloom.sourceforge.net/sh.html) for example, but for a contemporary list of portable shell capabilities, see the [The Open Group spec](https://www.opengroup.org/onlinepubs/9699919799/) which describes the POSIX standard. Note also the [Autoconf info](https://www.gnu.org/software/autoconf/manual/html_node/Portable-Shell.html) on shell portability which lists details you need to consider when writing *very* portable shell scripts, and the ubuntu [dash conversion info](https://wiki.ubuntu.com/DashAsBinSh).

It's much better to test scripts directly in a POSIX compliant shell if possible. The `bash --posix` option doesn't suffice as it still accepts some "bashisms", but the `dash` shell which is the default interpreter of shell scripts on ubuntu is very good in this regard. One should be testing with this shell anyway due to the popularity of ubuntu, and dash is easy to install on Fedora for example.

### bashisms

`bash` is the most common interactive shell used on unix systems, and consequently, syntax specific to `bash` is often used in shell scripts. Note I've never needed to resort to bash specific constructs in my scripts. If you find yourself doing complex string manipulations or loops in bash, then you should probably be considering existing UNIX tools instead, or a more general scripting language like python for example.

### [ "$var" == "find" ] && echo "found"

Shell script can't assign variable values in conditional constructs so the double equals is redundant. Moreover it gives a syntax error on older busybox (ash) and dash at least, so avoid it.

### echo {not,portable}

Brace expansion is not portable. While useful it's mostly so at the interactive prompt, and can easily be worked around in scripts.

### signal specifications

Be wary of when specifying signals to the trap builtin for example, which was mentioned [above](http://www.pixelbeat.org/programming/shell_script_mistakes.html#trap). I was even caught out by this in my [timeout](http://www.pixelbeat.org/scripts/timeout) script. That script handles the "CHLD" signal which for bash at least can be specified as "sigchld", "SIGCHLD", "chld", "17" or "CHLD", only the last of which is portable.

### echo $(seq 15) $((0x10))

The command above containing both $(command substitution) and an $((arithmetic expression)) *is* portable. Traditionally one did command substitution using backquotes like `seq 15`. That's awkward to nest though and not very readable in the presence of other quoting. $((arithmetic expressions)) can be handy also for quick calculations, rather than spawning off `bc` or `expr` for example. Note bash supports the non portable form of $[1+1] for arithmetic expressions which you should avoid. Note also that vim 7.1.135 at least, highlights $() as a syntax error unless #!/bin/bash it at the top of the script--- I must send [a patch](http://www.pixelbeat.org/patches/vim-7.1.135-sh-paren.diff). [**Update** June 2008: Strangely it looks like vim explicitly chooses to highlight #!/bin/sh scripts as original bourne shell scripts rather than to the POSIX standard which the vast majority of systems currently use. I've [asked](https://groups.google.com/group/vim_dev/t/41139a32772b2f5f) for this to be changed, but in the meantime you can add "let g:is_posix = 1" to your [.vimrc](http://www.pixelbeat.org/settings/.vimrc)]

### echo --help

[**Update** March 2011: I've used echo in all the examples above for convenience, but one should be wary about using it, especially if you pass variable parameters. `echo` implementations vary on how they handle escaped characters and options, so one really should use `**printf**` instead, as it has a more standard implementation across systems.]

Performance
-----------

We'll expand here on our globbing example [above](http://www.pixelbeat.org/programming/shell_script_mistakes.html#globbing) to illustrate some performance characteristics of the shell script interpreter. Comparing the `bash` and `dash` interpreters for this example where a process is spawned for each of 30,000 files, shows that dash can fork the `wc` processes nearly twice as fast as `bash`

$ time dash -c 'for i in *; do wc -l -- "$i">/dev/null; done'
real    0m14.440s
user    0m3.753s
sys     0m10.329s

$ time bash -c 'for i in *; do wc -l -- "$i">/dev/null; done'
real    0m24.251s
user    0m8.660s
sys     0m14.871s

Comparing the base looping speed by not invoking the `wc` processes, shows that dash's looping is nearly 6 times faster!

$ time bash -c 'for i in *; do echo "$i">/dev/null; done'
real    0m1.715s
user    0m1.459s
sys     0m0.252s

$ time dash -c 'for i in *; do echo "$i">/dev/null; done'
real    0m0.375s
user    0m0.169s
sys     0m0.203s

The looping is still relatively slow in either shell as [demonstrated previously](http://www.pixelbeat.org/programming/readline/), so for scalability we should try and use more [functional](http://www.pixelbeat.org/talks/linux_and_python/page15.html)techniques so iteration is performed in compiled processes.

$ time find -type f -print0 | wc -l --files0-from=- | tail -n1
    30000 total
real    0m0.299s
user    0m0.072s
sys     0m0.221s

The above is by far the most efficient solution and illustrates the point well that one should do as little as possible in shell script and aim just to use it to connect the existing logic available in the rich set of utilities available on a UNIX system.

### disk seeks

It's worth giving special mention to this since disk seeks are so expensive, and since shell script is designed to deal with files which commonly reside on disks. If you check for the presence of 2 files for example with [ -e FOO -o -e BAR ], then the check isn't short circuited and 2 disk seeks are performed. The bash specific format of [ -e FOO || -e BAR ] does short circuit the second test, however it's better to use the [ -e FOO ] || [ -e BAR ] conditional format which is both portable and efficient. Traditionally this last example would have used 2 processes, one for each of the '['. But modern shells implement '[' internally, so there is no such overhead.

[©](https://creativecommons.org/licenses/by-sa/3.0/) May 13 2008
