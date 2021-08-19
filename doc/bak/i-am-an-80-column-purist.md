I AM AN 80 COLUMN PURIST
========================

[NOVEMBER 30, 2020](https://daniel.haxx.se/blog/2020/11/30/i-am-an-80-column-purist/) [DANIEL STENBERG](https://daniel.haxx.se/blog/author/daniel/) [8 COMMENTS](https://daniel.haxx.se/blog/2020/11/30/i-am-an-80-column-purist/#comments)

I write and prefer code that fits within 80 columns in [curl](https://curl.haxx.se/) and other projects -- and there are reasons for it. I'm a little bored by the people who respond and say that they have 400 inch monitors already and they can use them.

I too have multiple large high resolution screens -- but writing wide code is still a bad idea! So I decided I'll write down my reasoning once and for all!

Narrower is easier to read
--------------------------

There's a reason newspapers and magazines have used narrow texts for centuries and in fact even books [aren't using long lines](https://en.wikipedia.org/wiki/Line_length). For most humans, it is simply easier on the eyes and brain to read texts that aren't using really long lines. This has been known for a very long time.

Easy-to-read code is easier to follow and understand which leads to fewer bugs and faster debugging.

Side-by-side works better
-------------------------

I never run windows full sized on my screens for anything except watching movies. I frequently have two or more editor windows next to each other, sometimes also with one or two extra terminal/debugger windows next to those. To make this feasible and still have the code readable, it needs to fit "wrapless" in those windows.

Sometimes reading a code diff is easier side-by-side and then too it is important that the two can fit next to each other nicely.

Better diffs
------------

Having code grow vertically rather than horizontally is beneficial for diff, git and other tools that work on changes to files. It reduces the risk of merge conflicts and it makes the merge conflicts that still happen easier to deal with.

It encourages shorter names
---------------------------

A side effect by strictly not allowing anything beyond column 80 is that it becomes really hard to use those terribly annoying 30+ letters java-style names on functions and identifiers. A function name, and especially local ones, should be short. Having long names make them really hard to read and makes it really hard to spot the difference between the other functions with similarly long names where just a sub-word within is changed.

I know especially Java people object to this as they're trained in a different culture and say that a method name should rather include a lot of details of the functionality "to help the user", but to me that's a weak argument as all non-trivial functions will have more functionality than what can be expressed in the name and thus the user needs to know how the function works anyway.

I don't mean 2-letter names. I mean long enough to make sense but not be ridiculous lengths. Usually within 15 letters or so.

Just a few spaces per indent level
----------------------------------

To make this work, and yet allow a few indent levels, the code basically have to have small indent-levels, so I prefer to have it set to two spaces per level.

Many indent levels is wrong anyway
----------------------------------

If you do a lot of indent levels it gets really hard to write code that still fits within the 80 column limit. That's a subtle way to suggest that you should not write functions that needs or uses that many indent levels. It should then rather be split out into multiple smaller functions, where then each function won't need that many levels!

Why exactly 80?
---------------

Once upon the time it was of course because terminals had that limit and these days the exact number 80 is not a must. I just happen to think that the limit has worked fine in the past and I haven't found any compelling reason to change it since.

It also has to be a hard and fixed limit as if we allow a few places to go beyond the limit we end up on a slippery slope and code slowly grow wider over time -- I've seen it happen in many projects with "soft enforcement" on code column limits.

Enforced by a tool
------------------

In [curl](https://curl.se/), we have 'checksrc' which will yell errors at any user trying to build code with a too long line present. This is good because then we don't have to "waste" human efforts to point this out to contributors who offer pull requests. The tool will point out such mistakes with ruthless accuracy.
