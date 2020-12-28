# **The Pull Request Hack**

March 11, 2013

Published:

After writing about [Open Source And Responsibility](https://felixge.de/2013/03/07/open-source-and-responsibility.html), I'd like to share a small collaboration hack I came up with last year. Here it is:

Whenever somebody sends you a pull request, give them commit access to your project.

While it may sound incredible stupid at first, using this strategy will allow you to unleash the true power of Github. Let me explain. Over the past year, I realized that I could not allocate enough time to my open source projects anymore. And I'm not even talking about fixing bugs or adding features, I'm talking about pull requests piling up.

So why wouldn't I simply merge them? Well, a lot of them were actually not good enough. They were lacking tests or documentation, violated coding standards, or were introducing new issues the contributor had not considered. I would often explain the problems in detail, only to find that the contributor was now lacking the time to make the changes. Of course I could make those adjustments myself, but that would often take as much time as if I had done the patch myself to begin with. So after seeing this pattern play out many times over, I started to neglect most incoming pull requests that couldn't be merged right away.

And then I came across the hack I mentioned above. I wish I could take credit for designing it, but it really happened by coincidence. Somebody sent a pull request for a project I was no longer using myself, and I could see an issue with it right away. However, since I no longer cared about the project, and the person sending the pull request did, I simply added him as a collaborator and said something like this: &quot;I don't have time to maintain this project anymore, so I gave you commit access to make any changes you'd like. It would be nice to follow the style used by the rest of the code and add some tests to this patch.&quot;.

The result was pure magic. Within a few hours the same person who had just submitted a rather mediocre patch, had now fixed things up and committed them. This was highly unusual, so I started using the same strategy for a few other small projects I was no longer interested in maintaining. And it worked, over and over again. Of course, sometimes it wouldn't make a difference, but it was clearly working a lot better than my previous approach.

Given the success for my smaller projects, I eventually decided to also try it for my two most popular projects, [node-mysql](https://github.com/felixge/node-mysql) and [node-formidable](https://github.com/felixge/node-formidable). Initially I was very worried about giving up control over these projects, but the results speak for themselves. Both projects are now maintained by a bunch of amazing developers, writing much better code than I ever received in the form of pull requests before.

So why does it work? Well, I have a few ideas. Once people have commit access, they are no longer worried that their patch might go unmerged. They now have the power to commit it themselves, causing them to put much more work into it. Doing the actual commit/push also changes their sense of ownership. Instead of handing over a diff to somebody else, they are now part of the project, owning a small part of it.

But the magic does not stop here. In addition to their contribution quality going up, I've observed many people continuing to help out with issues and patches sent by other users. This is of course fueled by Github notifying every contributor on a repository of all activity on it.

So should you really do this for all pull requests? Probably not. While I've given a large amount of users access to various projects of mine, I'm still looking for:

- Github profile: Does this user stand to lose a reputation by doing something stupid?
- Skill: Based on the patch, do I think the user could be a good developer?
- Usefulness: Is this patch solving a valid problem?

With these checks in place, I think this approach is a fantastic way to keep projects from going stale as well as turning one man projects into small communities. However, you're obviously free to run your projects any way you'd like.

Last but not least, I'd like to thank a few of the great people who have made significant contributions to some of my projects recently:

- [Diogo Resende](https://github.com/dresende) for maintaining the hell out of [node-mysql](https://github.com/felixge/node-mysql).
- [Oz Wolfe](https://github.com/CaptainOz) for contributing a connection pool to [node-mysql](https://github.com/felixge/node-mysql).
- [Nate Lillich](https://github.com/NateLillich) for improving the connection pool for [node-mysql](https://github.com/felixge/node-mysql).
- [Sven Lito](https://github.com/svnlto) for fixing bugs and merging patches for [node-formidable](https://github.com/felixge/node-formidable).
- [@egirshov](https://github.com/egirshov) for contributing many improvements to the [node-formidable](https://github.com/felixge/node-formidable) multipart parser.
- [Andrew Kelley](https://github.com/superjoe30) for also helping with fixing bugs and making improvements to [node-formidable](https://github.com/felixge/node-formidable).
- [Mike Frey](https://github.com/mikefrey) for contributing JSON support to [node-formidable](https://github.com/felixge/node-formidable).
- [Alex Indigo](https://github.com/alexindigo) for putting serious amounts of work into improving and maintaining [node-form-data](https://github.com/felixge/node-form-data).
- [Domenic Denicola](https://github.com/domenic) for doing a lot of improvements on [node-sandboxed-module](https://github.com/felixge/node-sandboxed-module).
- Everybody else who I forgot to mention or who made smaller contributions.

You guys are absolutely amazing and I can't thank you enough for all the help.

**Update:** Looking back at it, talking to [Peter Hintjens](https://twitter.com/hintjens) at [MixIT](http://www.mix-it.fr/) was definitley an inspiration for this.

**Update 2:** There is an interesting discussion about this on [Hacker News](http://news.ycombinator.com/item?id=5357417) right now, seems like others have used this strategy with success as well!

**Update 3:** There is even more discussions going on at [Reddit](http://www.reddit.com/r/programming/comments/1a7gns/whenever_somebody_sends_you_a_pull_request_give/).

-- Felix Geisendörfer

Subscribe to this blog via [RSS](https://feeds.feedburner.com/felixge) or [E-Mail](https://feedburner.google.com/fb/a/mailverify?uri=felixge) or get small updates from me via [Twitter](https://twitter.com/felixge).
