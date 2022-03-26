One Pull Request. One Concern. 🔊
=================================

The importance of a Pull Request lies on the definition of an atomic concern
----------------------------------------------------------------------------

![](https://miro.medium.com/max/1400/1*0LyFL_tdxEhlM5eh_MeRfQ.jpeg)

Obama, looking down. Concerned with something.

Listen to the audio version!

Git has a command called `[git-request-pull](https://git-scm.com/docs/git-request-pull)`. The purpose of the command is to prepare a set of commits so that the owner of a copy of a project can request to the owner of another copy to land a small set of changes. The idea is to be able to share a piece of functionality with the owner of a more trusted version of the project, without requiring additional write access. This opens a wide range of opportunities for collaboration: anyone can clone a trusted project, make changes, and then ask the original author to land those changes.

When Github came out, it leveraged the philosophy of Git and ["forked"](https://en.wikipedia.org/wiki/Fork_%28software_development%29) the idea behind `git-request-pull`. The purpose was to create an abstraction on top of it so that those who are not familiarized with Git could understand and apply the philosophy of collective collaboration without having to setup mailing lists.

They called it [Pull Request](https://help.github.com/articles/using-pull-requests/).

A Pull Request serves a similar underlying purpose of `git-request-pull`, with the difference that it deeply integrates something that was one of the main reasons for the success of Github:

Collaboration.

> A Pull Request is a successful attempt to deeply integrate collaboration to the developer's workflow

Different from the distributed nature of Git, a Pull Request is not just a way to "prepare" a set of commits so that it can be sent to the owner of another copy of the project through external means (such as e-mail). A Pull Request **is the set of commits**, that also contains the technical history of everything that was related to that Pull Request. All in a single place.

There are [strong objections](https://github.com/torvalds/linux/pull/17#issuecomment-5654674) to some fundamental decisions and trade-offs of the "Pull Request" approach. What can't be denied, is that Github successfully accomplished its goal, which was to make text collaboration (not just code) more accessible to everyone, providing an interface so simple that even those who can't program can still collaborate.

Last time, I wrote an article called ["One Commit. One Change."](https://fagnerbrack.com/one-commit-one-change-3d10b10cebbf). It explained that a commit represents a single atomic change, an indivisible change. It can **succeed** entirely or it can fail entirely, but it cannot **partly succeed**.

In a Git commit, we measure "succeed" as the ability of the code to deliver value to the application. "Value" is not just about business value, it can represent payment of a technical debt, legibility fixes or internal interface changes, but it cannot contain certain refactoring or whitespace changes that don't have a clear purpose and therefore can succeed even if part of the change is omitted.

A Github Pull Request (from now on just "Pull Request") is more than just a set of commits.

While a commit can only contain a single change, a Pull Request can contain one or more changes that together form a high-level concern.

> A Pull Request represents a way to deliver value to the application in the form of a set of changes that together form a high-level concern

It is also important for a Pull Request to be atomic. But with a Pull Request, we measure the "succeed" as the ability to deliver the smallest possible piece of functionality, it can either be composed of one or many atomic commits.

One of the bad practices of a Pull Request is changing things that are not concerned with the functionality that is being addressed, like whitespace changes, typo fixes, variable renaming, etc. If those things are not related to the concern of the Pull Request, it should probably be done in a different one.

One might argue that this practice of not mixing different concerns and small fixes in the same Pull Request ignores the [Boy Scout Rule](http://deviq.com/boy-scout-rule/) because it doesn't allow frequent cleanup. However, cleanup doesn't need to be done in the same Pull Request, the important thing is not leaving the codebase in a bad state after finishing the functionality. If you must, refactor the code in a separate Pull Request, and preferably **before** the actually concerned functionality is developed, because then if there is a need in the near future to revert the Pull Request, the likelihood of code conflict will be lower.

It is important to note that, on the Linux kernel mailing list, the `git-request-pull` command is used by maintainers of some copies of the kernel to sync their trees into larger ones and eventually into the mainline, and that might not contain a single concern. For a single concern they use a "patch set", or "patch series":

> On the Linux kernel mailing list, patch sets are used for grouping atomic changes and should have what the author calls one concern. Pull requests are usually used by subtree maintainers to sync their trees into larger trees and eventually into the mainline. In this case, pull requests can contain patches from many community members that the maintainer has applied to his/her tree in which case pull requests do not address a single concern [...]
>
> --- User [**mdmd136**](https://www.reddit.com/user/mdmd136) on [Reddit](https://www.reddit.com/r/git/comments/4nnznq/one_pull_request_one_concern/d45p3uo)

But what does "patch set" means in the context of the Linux kernel development mailing list?

> [...] The cover letter does not contain a patch, but describes the theme of the entire patch series and usually has a diff stat of the set [...]
>
> --- Excerpt from [**mdmd136**](https://www.reddit.com/user/mdmd136)'s [comment](https://www.reddit.com/r/git/comments/4nnznq/one_pull_request_one_concern/d48lra2)

A Pull Request shares the same fundamental purpose of `git-request-pull`, with the difference that it is useful to express the intent of a single atomic concern, something that most of the time shouldn't be done using only a single commit.

Most of the atomicity advantages of a commit are also advantages of a Pull Request but at a higher level.

It doesn't matter [which workflow you've chosen](https://www.atlassian.com/git/tutorials/comparing-workflows/), using Pull Requests efficiently containing an atomic concern can help to scale the codebase through collaboration.

Thanks for reading. If you have some feedback, reach out to me on [Twitter](https://twitter.com/FagnerBrack), [Facebook](https://www.facebook.com/fagner.brack) or [Github](http://github.com/FagnerMartinsBrack).
