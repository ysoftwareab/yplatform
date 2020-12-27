# **Know Your Tools: Linux (GNU) vs. Mac (BSD) Command Line Utilities**

[Jonathon Poling](https://ponderthebits.com/author/jp/)

Welcome to first post in the "Know Your Tools" series!

Without further ado…

Have you ever wondered if/how \*nix command line utilities may differ across distributions? Perhaps it never even occurred to you that there was even a possibility the tools were any different. I mean, they're basic command line tools. How and why could/would they possibly differ?

Well, I'm here to say… thy basic command line utilities art not the same across different distributions. And, the differences can range from those that can cause a simple nuisance to those that can cause oversight of critical data.

Rather than going into aspects of this discussion that have already been covered such as how [Linux](http://www.makeuseof.com/tag/linux-vs-bsd-which-should-you-use/) and [BSD](https://www.freebsd.org/doc/en/articles/explaining-bsd/comparing-bsd-and-linux.html)[generally](https://news.ycombinator.com/item?id=12034277)[differ](http://www.howtogeek.com/190773/htg-explains-whats-the-difference-between-linux-and-bsd/), I would instead like to focus on a few core utilities commonly used in/for DFIR artifact analysis and some caveats that may cause you some headache or even prevent you from getting the full set of results you'd expect. In highlighting the problems, I will also help you identify some workarounds I've learned and developed over the years in addressing these issues, along with an overarching solution at the end to install GNU core utilities on your Mac (should you want to go that route).

Let's get to it.

**Grep**

Grep is one of the most useful command-line utilities for searching within files/content, particularly for the ability to use [regular expressions](http://www.regular-expressions.info/) for searching/matching. To some, this may be the first time you've even heard that term or "regex" (shortened version of it). Some of you may have been using it for a while. And, nearly everyone at some point feels like…

Amirite?

Regardless of whether this is your first time hearing about regular expressions or if you use them regularly albeit with some level of discomfort, I HIGHLY suggest you take the time to learn and/or get better at using them – they will be your most powerful and best friend for grep. Though there is a definite regex learning curve (it's really not that bad), knowing how to use regular expressions translates directly to performing effective and efficient searches for/of artifacts during an investigation.

Nonetheless, even if you feel like a near master of regular expressions, equally critical to an expression's success is how it is implemented within a given tool. Specifically for grep, you may or may not be aware that it uses two different methods of matching that can highly impact the usefulness (and more important, validity) of results returned – Greedy vs. Lazy Matching. Let's explore what each of these means/does.

At a very high level, greedy matching attempts to find the last (or longest) possible match, and lazy matching attempts to find the first possible match (and stops there). More specifically, greedy matching employs what is called backtracking and look-behind's but that is a separate discussion. Suffice to say, using an incorrect, unintended, and/or unexpected matching method can completely overlook critical data or at the very least provide an inefficient or invalid set of results.

Now having established some foundational knowledge about how grep searches can work, we will drop the knowledge bomb – the exact same grep expression on Linux (using GNU grep) may produce completely different or no results on Mac (using BSD grep), especially when using these different types of matching.

…What? Why?

The first time I found this out I spent an inordinate and unnecessary amount of time banging my head against a wall typing and re-typing the same expression across systems but seeing different results. I didn't know what I didn't know. And, well, now I hope to let you know what I didn't know but painfully learned.

While there is an explanation of why, it doesn't necessarily matter for this discussion. Rather, I will get straight to the point of what you need to know and consider when using this utility across systems to perform effective searches. While GREEDY searches execute pretty much the same across systems, the main difference comes when you are attempting to perform a LAZY search with grep.

We'll start with GREEDY searches as there is essentially little to no difference between the systems. Let's perform a greedy search (find the last/longest possible match) for any string/line ending in "is" using grep's [Extended Regular Expressions](https://www.gnu.org/software/grep/manual/html_node/Basic-vs-Extended.html) option ("-E").

**(Linux GNU)$ echo**  **"**** thisis ****" | grep -Eo '.+is'**
thisis
**(Mac BSD)$ echo**  **"**** thisis ****" | grep -Eo '.+is'**
thisis

Both systems yield the same output using a completely transferrable command. Easy peasy.

Note: When specifying Extended Regular Expressions, you can (and I often do) just use "egrep" which implies the "-E" option.

Now, let's look at LAZY searches. First, how do we even specify a lazy search? Well, to put it simply, you append a "?" to your matching sequence. Using the same search as before, we'll instead use lazy matching (find the first/shortest match) for the string "is" on both the Linux (GNU) and Mac (BSD) versions of grep and see what both yield.

**(Linux GNU)$ echo**  **"**** thisis ****" | grep -Eo '****.+?is'**
thisis
**(Mac BSD)$ echo**  **"**** thisis ****" | grep -Eo '****.+?is'**
this

Here the fun begins. We did the exact same command on both systems and it returned different results.

Well, for LAZY searches, Linux (GNU) grep does NOT recognize lazy searches unless you specify the "-P" option (short for PCRE, which stands for Perl Compatible Regular Expressions). So, we'll supply that this time:

**(Linux GNU)$ echo**  **"**** thisis ****" | grep -Po '****.+?is'**
this

There we go. That's what we expected and hoped for.

\*Note: You cannot use the implied Extended expression syntax of "egrep" here as you will get a "conflicting matchers specified" error. Extended regex and PCRE are mutually exclusive in GNU grep.

Note that Mac (BSD), on the other hand, WILL do a lazy search by default with Extended grep. No changes necessary there.

While not knowing this likely won't lead to catastrophic misses of data, it can (and in my experience will very likely) lead to massive amounts of false positives due to greedy matches that you have to unnecessarily sift through. Ever performed a grep search and got a ton of very imprecise and unnecessarily large (though technically correct) results? This implementation difference and issue could certainly have been the cause. If only you knew then what you know now…

So, now that we know how these searches differ across systems (and what we need to modify to make them do what we want), let's see a few examples where using lazy matching can significantly help us (note: I am using my Mac for these searches, thus the successful use of Extended expressions using "egrep" to allow for both greedy and lazy matching)…

User-Agent String Matching

Let's say I want to identify and extract the OS version from Mozilla user-agent strings from a set of logs, the format of which I know starts with "Mozilla/" and then contains the OS version in parenthesis. The following shows some examples:

- _Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36_
- _Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2226.0 Safari/537.36_
- _Mozilla/5.0 (X11; Linux x86\_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36_
- _Mozilla/5.0 (Macintosh; Intel Mac OS X 10\_10\_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36_

Greedy Matching (matches more than we wanted – fails)

**(Mac BSD)$ echo "Mozilla/5.0 (Macintosh; Intel Mac OS X 10\_10\_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36" | egrep -o 'Mozilla.+\)'**
Mozilla/5.0 (Macintosh; Intel Mac OS X 10\_10\_1) AppleWebKit/537.36 (KHTML, like Gecko)

Lazy Matching

**(Mac BSD)$ echo "Mozilla/5.0 (Macintosh; Intel Mac OS X 10\_10\_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36" | egrep -o 'Mozilla.+?\)'**
Mozilla/5.0 (Macintosh; Intel Mac OS X 10\_10\_1)

Searching for Malicious Eval Statements

Let's say I want to identify and extract all of the base64 eval statements from a possibly infected web page for analysis, so that I can then pipe it into sed to extract only the base64 element and decode it for plaintext analysis.

Greedy Matching (matches more than we wanted – fails)

**(Mac BSD)$ echo "date=new Date(); eval(base64\_decode(\"DQplcnJvcl9yZ=\")); var ua = navigator.userAgent.toLowerCase();" | egrep -o 'eval\(base64\_decode\(.+\)'**
eval(base64\_decode("DQplcnJvcl9yZ=")); var ua = navigator.userAgent.toLowerCase()

Lazy Matching (matches exactly what we want)

**(Mac BSD)$ echo "date=new Date(); eval(base64\_decode(\"DQplcnJvcl9yZ=\")); var ua = navigator.userAgent.toLowerCase();" | egrep -o 'eval\(base64\_decode\(.+?\)'**
eval(base64\_decode("DQplcnJvcl9yZ="))

There you have it. Hopefully you are now a bit more informed not only about the differences between Lazy and Greedy matching, but also about the difference in requirements across systems.

**Strings**

Strings is an important utility for use in extracting "human-readable" strings from files/binaries. It is particularly useful in extracting strings from (suspected) malicious binaries/files to attempt to acquire some insight into what may be contained within the file, its capabilities, hard-coded domains/URL's, commands, … the list goes on.

However, not all strings are created equal. Sometimes, Unicode strings exist within a file/program/binary for various reasons, those of which are also important to identify and extract. By default, the GNU (Linux) strings utility searches for simple [ASCII](https://en.wikipedia.org/wiki/ASCII) encoding, but also allows you to specify additional encodings for which to search, to include Unicode. Very useful.

By default, the Mac (BSD) strings utility also searches for simple ASCII encoding; however, I regret to inform you that the Mac (BSD) version of strings does NOT have the native capability to search for Unicode strings. Do not ask why. I highly encourage you to avoid the rabbit hole of lacking logic that I endured when I first found this out. Instead, we should move on and instead just be asking ourselves, "What does this mean to me?" Well, if you've only been using a Mac to perform string searches using the native BSD utility, you have been MISSING ALL UNICODE STRINGS. Of all the pandas, this is a very sad one.

So, what are our options?

There are several options, but I personally use one of the following (depending no the situation and my mood) when I need to extract both Unicode and ASCII strings from a file using a Mac (BSD) system:

1. [Willi Ballenthin's Python strings tool](https://gist.github.com/williballenthin/8e3913358a7996eab9b96bd57fc59df2) to extract both ASCII and Unicode strings from a file

2. FireEye's [FLOSS](https://github.com/fireeye/flare-floss) tool (though intended for binary analysis, it can also work against other types of files)

3. GNU strings\*

\*Wait a minute. I just went through saying how GNU strings isn't available as a native utility on a Mac. So, how can I possibly use GNU strings on it? Well, my friends, at the end of this post I will revisit exactly how this can be achieved using a nearly irreplaceable third-party package manager.

Now, go back and re-run the above tools against various files and binaries from your previous investigations you performed from the Mac command line. You may be delighted at what new Unicode strings are now found 🙂

**Sed**

Sed (short for "Stream editor") is another useful utility to perform all sorts of useful text transformations. Though there are many uses for it, I tend to use it mostly for substitutions, deletion, and permutation (switching the order of certain things), which can be incredibly useful for log files with a bunch of text.

For example, let's say I have a messy IIS log file that somehow lost all of its newline separators and I want to extract just the HTTP status code, method, and URI from each line and output into its own separate line (restoring readability):

…_2016-08-0112:31:16HTTP200GET/owa2016-08-0112:31:17HTTP200GET/owa/profile2016-08-0112:31:18HTTP404POST/owa/test__…_

Looking at the pattern, we'd like to insert a newline before each instance of the date, beginning with "2016-…". Lucky for us, we're on a Linux box with GNU sed and it can easily handle this:

**(Linux GNU)$ sed 's/ \(.+\?\)2016/\1\n2016/g' logfile.txt**
2016-08-0112:31:16HTTP200GET/owa
2016-08-0112:31:17HTTP200GET/owa/profile
2016-08-0112:31:18HTTP404POST/owa/test
...

You can see that it not only handles lazy matching, but also handles ANSI-C escape sequences (e.g., \n, \r, \t, …). This statement also utilizes sed variables, the understanding of which I will leave to the reader to explore.

Sweet. Let's try that on a Mac…

**(Mac BSD)$ sed 's/\(.+\?\)\(.+\)/\1\n2016/g' logfile.txt**
2016-08-0112:31:16HTTP200GET/owa2016-08-0112:31:17HTTP200GET/owa/profile2016-08-0112:31:18HTTP404POST/owa/test

… Ugh. No luck.

Believe it or not, there are actually two common problems here. The first is the lack of interpretation of ANSI-C escape sequences. BSD sed simply doesn't recognize any (except for \n, but not within the replacement portion of the statement), which means we have to find a different way of getting a properly interpreted newline into the statement.

Below are a few options that will work around this issue (and there are more clever ways to do it as well).

1. Use the literal (i.e., for a newline, literally insert a new line in the expression)

(Mac BSD)$ sed 's//\ **\*Press Enter\***
\&gt; /g'

2. Use bash ANSI-C Quoting (I find this the easiest and least effort, but YMMV)

(Mac BSD)$ sed 's// **\'$'\n** /g'

3. Use Perl

(Mac BSD)$ perl -pe 's||\n|g'

Unfortunately, this only solves the first of two problems, the second being that BSD sed still does not allow for lazy matching (from my testing, though I am possibly just missing something). So, even if you use #1 or #2 above, it will only match the last found pattern and not all the patterns we need it to.

"So, should I bother with using BSD sed or not?"

Well, I leave that up to your judgment. Sometimes yes, sometimes no. In cases like this where you need to use both lazy matching and ANSI-C escape sequences, it may just be easier to skip the drama and use Perl (or perhaps you know of another extremely clever solution to this issue). Options are always good.

Note: There are also other issues with BSD sed like [line numbers](http://stackoverflow.com/questions/29334537/sed-on-linux-vs-freebsd) and using the ["-i" parameter](http://stackoverflow.com/questions/2320564/variations-of-sed-between-osx-and-gnu-linux). Should you be interested beyond the scope of this post, [this StackExchange thread](http://unix.stackexchange.com/questions/13711/differences-between-sed-on-mac-osx-and-other-standard-sed) actually has some useful information on the differences between GNU and BSD sed. Though, I've found that YMMV on posts like this where the theory and "facts" may not necessarily match up to what you find in testing. So, when in doubt, always test for yourself.

**Find**

Of all commands, you might wonder how something so basic as _find_ could differ across \*nix operating systems. I mean, what could possibly differ? It's just _find_, the path, the type, the name… how or why could that even be complicated? Well, for the most part they are the same, except in one rather important use case – using find with regular expressions (regex).

Let's take for example a regex to find all current (non-archived/rotated) log files.

On a GNU Linux system this is somewhat straight forward:

**(Linux GNU)$ find /var/log -type f -regextype posix-extended -regex "/var/log/[a-zA-Z\.]+(/[a-zA-Z\.]+)\*"**

You can see here that rather than using the standard "-name" parameter, we instead used the "-regextype" flag to enable extended expressions (remember egrep from earlier?) and then used the "-regex" flag to denote our expression to utilize. And, that's it. Bless you, GNU!

Obviously, Mac BSD is not this straight forward, otherwise I wouldn't be writing about it. It's not exactly SUPER complicated, but it's different enough to cause substantial frustration as your Google searches will show that the internet is very confused about how to do this properly. I know. Shocking. Nonetheless, there is value in traveling down the path of frustration here so that you don't have to when it really matters. So, let's just transfer the command verbatim over to a Mac and see what happens.

**(Mac BSD)$ find /var/log -type f -regextype posix-extended -regex "/var/log/[a-zA-Z\.]+(/[a-zA-Z\.]+)\*"**
find: -regextype: unknown primary or operator

Great, because why would BSD find use the same operators, right? That would be too easy. By doing a "man find" (on the terminal, not in Google, as that will produce very different results from what we are looking for here) you will see that BSD find does not use that operator. Though, it still does use the "-regex" operator. Easy enough, we'll just remove that bad boy:

**(Mac BSD)$ find /var/log -type f -regex "/var/log/[a-zA-Z\.]+(/[a-zA-Z\.]+)\***

**(Mac BSD)$**

No results. Ok. Let's look at the manual again… ah ha, to enable extended regular expressions (brackets, parenthesis, etc.), we need to use the "-E" option. Easy enough:

**(Mac BSD)$ find /var/log -E -type f -regex "/var/log/[a-zA-Z\.]+(/[a-zA-Z\.]+)\*"**
find: -E: unknown primary or operator

Huh? The manual says the "-E" parameter is needed, yet we get the same error message we got earlier about the parameter being an unknown option. I'll spare you a bit of frustration and tell you that it is VERY picky about where this flag is put – it must be BEFORE the path, like so:

**(Mac BSD) $\&gt; find -E /var/log -type f -regex "/var/log/[a-zA-Z\.]+(/[a-zA-Z\.]+)\*"**
/var/log/alf.log
/var/log/appfirewall.log
/var/log/asl/StoreData
/var/log/CDIS.custom
/var/log/corecaptured.log
/var/log/daily.out
/var/log/DiagnosticMessages/StoreData
/var/log/displaypolicyd.log
/var/log/displaypolicyd.stdout.log
/var/log/emond/StoreData
/var/log/install.log
/var/log/monthly.out
/var/log/opendirectoryd.log
/var/log/powermanagement/StoreData
/var/log/ppp.log
/var/log/SleepWakeStacks.bin
/var/log/system.log
/var/log/Tunnelblick/tunnelblickd.log
/var/log/vnetlib
/var/log/weekly.out
/var/log/wifi.log

Success. And, that's that. Nothing earth shattering here, but different and unnecessarily difficult enough to be aware of in your switching amongst systems.

**So, now what?**

Are you now feeling a bit like you [know too much](https://cdn.meme.am/instances/45922155.jpg) about these little idiosyncrasies? Well, there's no going back now. If for no other reason, maybe you can use them to sound super smart or win bets or something.

These are just a few examples relevant to the commands and utilities often used in performing DFIR. There are still plenty of other utilities that differ as well that can make life a pain. So, now that we know this, what can we do about it? Are we doomed to live in constant translation of GNU \&lt;—\&gt; BSD and live without certain GNU utility capabilities on our Macs? Fret not, there is a light at the end of the tunnel…

If you would like to not have to deal with many of these cross-platform issues on your Mac, you may be happy to know that the GNU core utilities can be rather easily installed on OS X. There are a few options to do this, but I will go with my personal favorite method (for a variety of reasons) called Homebrew.

[Homebrew](http://brew.sh/) (or brew) has been termed "The missing package manager for OS X", and rightfully so. It allows simple command-line installation of a huge set of incredibly useful utilities (using [Formulas](https://github.com/Homebrew/homebrew-core/tree/master/Formula)) that aren't installed by default and/or easily installed via other means. And, the GNU core utilities are no exception.

As a resource, [Hong's Technology Blog](https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/) provides a great walk-through of installation and considerations.

You may already be thinking, "Great! But wait… how will the system know which utility I want to run if both the BSD and GNU version are installed?" Great question! By default, homebrew installs the binaries to _/usr/local/bin_. So, you have a couple options, depending on which utility in particular you are using. Some GNU utilities (such as sed) are prepended with a "g" and can be run without conflict (e.g., "gsed" will launch GNU sed). Others may not have the "g" prepended. In those cases, you will need to make sure that _/usr/local/bin_ is in your path (or has been [added to it](https://coolestguidesontheplanet.com/add-shell-path-osx/)) AND that it _precedes_ those of the standard BSD utilities' locations of _/usr/bin_, _/bin_, etc. So, your path should look something like this:

**$ echo $PATH**
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

With that done, it will by default now launch the GNU version installed in _/usr/local/bin_ instead of the standard system one located in /usr/bin. And, to use the native system utilities when there is a GNU version installed with the same name, you will just need to provide their full path (i.e., "/usr/bin/\&lt;utility\&gt;").

Please feel free to sound off in the comments with any clever/ingenious solutions not covered here or stories of epic failure in switching between Linux and Mac systems 😃

/JP
