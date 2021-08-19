# Maximum line length

We follow a hard line wrapping at 120 cpl (characters per line), and soft line wrapping at 80 cpl.

What this means is that editors should show two rulers at 80, and respectively 120 cpl,
and that we try not to reach the first ruler, but that it is fine to go up to the second ruler, if/when needed.

In very very rare cases e.g. regular expressions, we need/want to go above 120 cpl, and that's fine.
Just append a comment to the end of the line to please the editorconfig-checker
e.g. `# editorconfig-checker-disable-line` or `// editorconfig-checker-disable-line`.
There are less than 50 instances of such exceptions as of 2021-08-18. Very very few that is.


## But why?

TL;DR: shorter lines = better comprehension. Reading code is not the same as reading prose, yes.
But that doesn't imply that all reasearch is redundant or that the former becomes a false statement.
So while typography findings (mostly focused on prose) shouldn't be taken ad-literam (we engineers like strict limits),
it is important not to ignore them. That's why while the findings point at really really short lines,
while history had us at 80 cpl (punchcards), code with all its keywords and indentation
could be given some slack, but not deregulated.


## Anyone to back you up?

[Wikipedia](https://en.wikipedia.org/wiki/Line_length#Electronic_text): Researchers have suggested
that longer lines are better for quick scanning, while shorter lines are better for accuracy.
Longer lines would then be better suited for cases when the information will likely be scanned,
while shorter lines would be appropriate when the information is meant to be read thoroughly.
One proposal advanced that,
in order for on-screen text to have the best compromise between reading speed and comprehension,
about 55 cpl should be used.

Read why Daniel Stenberg (curl maintainer) is
[an 80-column purist](https://daniel.haxx.se/blog/2020/11/30/i-am-an-80-column-purist/).
[Comments on HN](https://news.ycombinator.com/item?id=25251494).

Read why 40-90 cpl is an optimal line length, [here](https://baymard.com/blog/line-length-readability)
and [here](https://www.semanticscholar.org/paper/Markus-Itkonen-Typography-and-readability-Itkonen-groteski/4b67cd16136d47682f547619e705e2151d2b98df).

Because displays have grown in size and resolution in the last few years.
[Eyes haven't.](https://stackoverflow.com/a/111009/465684)
