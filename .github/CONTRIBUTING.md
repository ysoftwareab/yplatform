# git (and Github) Pull Requests

**NOTE** Make sure that `make check` passes and maybe `make all test` as well,
before opening a Pull Request.

Once you are done with your feature branch and/or you would like to request feedback
and have it merged into master, it is time to initiate a Pull Request (short PR)
and have someone review your changeset.

When opening a Pull Request, or when reviewing someone else's Pull Request,
follow these guidelines:

0. Small is Best
1. Correct
2. Consistent
3. Clear
4. Share Knowledge


## 0. Small is Best

The changeset needs to focus on one thing and one thing alone.

This is good for both the author and the reviewer,
since the problem and the changeset addressing the problem is easier to parse and review,
resulting in a quick turnaround but also in higher quality of the review process.

See also:
* https://medium.com/@fagnerbrack/one-pull-request-one-concern-e84a27dfe9f1


## 1. Correct

The changeset needs to be comprehensive and logical.

Code changes should not only add new features or fix bugs, but also not introduce bugs.


## 2. Consistent

The changeset needs to be consistent with itself and with the existing codebase.

Coding paradigms and namings can always be improved in the eye of the beholder,
yet consistency should have a higher value.

When such improvements take place they should take place on their own,
and they should touch at least the whole repository, if not the whole system.


## 3. Clear

The changeset should be rather clear, not just in a working state.

This guideline may seem subjective, but clarity is not to be confused with personal preference.
It has much more to do with simplicity and productivity,
rather than with easy (how fast/easy it is for a person to read it).

See also:
* https://wildlyinaccurate.com/what-makes-code-readable/
* http://typicalprogrammer.com/what-does-code-readability-mean
* https://dave.cheney.net/2019/07/09/clear-is-better-than-clever


## 4. Share Knowledge

Given that the above guidelines/checks are fullfilled, the reviewer should have the liberty to point out
alternative code or useful functions/libraries, while the author has the liberty to assimilate or ignore them.

Take the opportunity of a PR to discuss and interact!


## Miscellaneous

**Stylistic comments are not to be part of a review.**
If anyone wants to address a stylistic issue, it should be done separately
by changing the automatism of the relevant style checker:
open a new PR to add/change a rule's configuration, in the current repository or globally in
e.g. `eslint-plugin-y`, `yplatform:build.mk/*.check.*.inc.mk` and similar.

A pull request may address an already existing issue.
In such a case, **make sure to reference the existing issue**, either in the commit message,
or in the description of the PR. See https://help.github.com/articles/closing-issues-using-keywords/.

A reviewer is required to act on the Pull Request only after the automated checks pass.


## The pull request hack

[If the pull request comes from an external collaborator,
consider giving them commit access to the repository.](https://felixge.de/2013/03/11/the-pull-request-hack/).

Code inevitably dies, but you're increasing the chances
that it might actually survive longer and evolve healthier than you expect.


## References

**MUST** read:
* https://www.atlassian.com/blog/git/written-unwritten-guide-pull-requests
* https://blog.philipphauer.de/code-review-guidelines/

Optional read:
* https://dev.to/samjarman/giving-and-receiving-great-code-reviews
* https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg
* https://blog.scottnonnenberg.com/top-ten-pull-request-review-mistakes/
* https://github.com/kubernetes/community/blob/master/contributors/guide/pull-requests.md
