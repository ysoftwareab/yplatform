# Kive - Frame Extraction Challenge (node.js)

Why this challenge in the first place? Because it offered a wide surface of solutions,
while adhering to "one thing well" principles. It also allowed me to challenge the list of challenges ;)

I also have not done any professional React, but it's a secondary issue.

The reasoning behind the proposed solution is

1. to not reinvent the wheel
2. to keep as many doors open for future development/specifications

One could easily get into fetching the HTML, finding maybe some youtube API, extracting the video url,
then manually downloading the video, and only then passing it through ffmpeg, then maybe processing the images, etc.
Going down this route is for me a good example for not having context, and starting to make assumptions:
that the problem is only about youtube videos, that the youtube html/api is stable,
that the videos are in a format you can pass on to your processing tool (ffmpeg) etc.

So instead I used a known tool: youtube-dl.

## Challenging the list of challenges

You can see that I've solved (hopefully!!!) the challenge as required - with NodeJS -,
but also with a bash script. Why on Earth would I do that?

Let me be cheeky and answer with a question: Why on Earth would you require this challenge to be solved specifically with NodeJS?
Is it the appropriate tool for the job? Is it that you want to restrict yourself to NodeJS and only NodeJS for all future problems?

A whole world is being reinvented in for one-off tools.
Yes, ffmpeg can be called from NodeJS/etc, and it can even be compiled in WASM,
but the real question is why do you want layers upon layers?
`ls`, `find` etc are all getting "reimplemented" in NodeJS for the sake of compatibility (with Windows).
I would say the correct word is "sub-implemented". Regardless, we will never solve cross-platform issues by porting sofware.
And the underlining issue is imo - a personality/language culture, a fear to learn the basics.
I haven't met one person that can tell me why do they write python for infrastructure tools.
I can totally get why python in the data science world though, as a counter-example :)

There's a serious list of deficiencies with the NodeJS script, that I'll skip in this README.

The other two challenges are suboptimal, if you ask me. They require multiple things to be solved at once.
With tools that are in your current stack, I understand, but not essential to the solution in itself.
Which is unfortunately a great way to attrack people that know or are familiar with the tools,
but may not be able to understand/reason around the problem.
Similarly it is a great way to put people that might be great at solving the problem,
but would stumble with tiny details specific to the tools you enforce.

## What's a great challenge then?

The best one that I've encountered in my interviews is one from Jayway.

https://github.com/rokmoln/support-firecloud/blob/robot/bin/robot.sh#L23-L90
