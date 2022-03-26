10 Principles of a Good Code Review
===================================

[#codequality](https://dev.to/t/codequality)[#productivity](https://dev.to/t/productivity)[#coding](https://dev.to/t/coding)[#codereview](https://dev.to/t/codereview)

EDIT: Rather like a code review itself, my peers have brought up some very good points on the comments section and Twitter. If you've already read this post, see my notes in the `EDIT` sections herein.

Also, read [Code Review Guidelines](https://blog.philipphauer.de/code-review-guidelines/) by Philipp Hauer

* * * * *

Nearly any healthy programming workflow will involve code review at some point in the process. This may be a Pull Request on GitHub, a Differential Revision on Phabricator, a Crucible Review on Atlassian, or any number of other review tools. But however you do it, not all code reviews are created equal.

At [MousePaw Media](https://mousepawmedia.com/), we have a strictly enforced workflow that includes a mandatory pre-commit code review. These have helped us catch many bugs and sub-optimal code.

Yet many interns are afraid to do code reviews, fearing they have little to contribute, especially when reviewing code written by developers who have been there much longer than they have! Meanwhile, the quality of code reviews - even my own - can vary greatly depending on many factors: familiarity with the code, time of day, time of day, you name it.

I've compiled thoughts and notes on code reviews from the last few years into a guide, which I published on our staff network documentation. I wanted to share the result (slightly adapted to dev.to).

I must give credit where credit is due! I drew a lot of inspiration from *[Top Ten Pull Request Review Mistakes](https://blog.scottnonnenberg.com/top-ten-pull-request-review-mistakes/)* by Scott Nonnenberg, *[Doing Terrible Things To Your Code](https://blog.codinghorror.com/doing-terrible-things-to-your-code/)* by Jeff Atwood, and *[Giving and Receiving Great Code Reviews](https://dev.to/samjarman/giving-and-receiving-great-code-reviews)*by Sam Jarman.

* * * * *

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#who-can-review)Who Can Review?
====================================================================================================

As I said, it can sometimes be daunting to review someone else's code, especially if that person has more experience, expertise, or seniority than you do. But don't be afraid! When everyone participates in code reviewing, everyone wins! Here are a couple of helpful things to remember.

First of all, everyone makes mistakes, and we know it! When a coder knows he or she will be code reviewed, it's like a safety net: they can more easily relax and code, knowing that another set of eyes will be reading this code before it's considered "done".

Second, everyone learns from a code review. The author gains additional insight on how to improve their code; the reviewer can learn new techniques and ideas from the code they're reviewing; the bystanders get the benefits of *both*.

In short, don't be afraid to contribute feedback! Code reviewing can be one of the most valuable contributions you can make to a project.

That said, what goes into a *good* review?

* * * * *

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#principle-1)Principle #1
==============================================================================================

The first and foremost principle of a good review is this: if you commit to review code, review it thoroughly! Expect to spend a decent amount time on this. Be sure to *read* the code, don't just skim it, and apply thought to both the code and its style.

In general, if you can't find anything specific to point out, either the code is perfect (almost never true) or you missed something. Thus, you can use this as a fairly accurate measure of how well you reviewed the code.

Aim to always suggest at least *one* specific improvement to the code (not just style) on the initial review. Follow-up reviews may not require this; otherwise we'd never land code!

EDIT: Especially if the code change is small, virtual perfection is absolutely possible. There may be reviews where no changes are needed at all, but you should be confident you put in the effort to actually arrive at this conclusion.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#principle-2)Principle #2
==============================================================================================

This goes hand-in-hand with the second principle: aim to understand every changed line. Research things you don't understand. Ask questions.

There are three major reasons why this is important:

1.  In truly elegant code, simple is usually better than complex. The only way to know if the best solution is being used is to *understand* the current solution.

2.  Other people may need to read this code. If you are having trouble understanding the code, it may need to be refactored, cleaned, or better commented.

3.  The more knowledge you have, the better your code and reviews will be!

When you're done, you should be able to answer two following questions for yourself:

-   "What goal does this code accomplish?"

-   "How does it accomplish this goal?"

If you cannot answer both questions, you don't fully understand the changes!

EDIT: You do NOT necessarily have to understand the whole code base. Generally, you should assume that unchanged code works, and merely glance back at it to confirm that it is being used correctly in the changed code.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#principle-3)Principle #3
==============================================================================================

Don't assume the code works - build and test it yourself! You should actually pull down the code and test it out. On Phabricator Differential, code submitted for pre-commit review includes a Test Plan from the author.

Of course, when testing code, make sure you're building correctly. If the project has a build system, you should be able to use it. If the Continuous Integration system reported successfully building the code, you should be able to as well.

On this note, if the CI build *failed*, you should require that the code successfully build before it can be landed!

Once you've compiled the code, *actually test it*. At MousePaw Media, most of our projects have a tester that provides space for arbitrary code; you can use this to try things out.

You should also run the included automatic tests, don't leave it at this. Try to break the code! If you wind up finding cases the automatic tests could cover better, suggest that these cases be accounted for in the tests.

Once again, take a look at *[Doing Terrible Things To Your Code](https://blog.codinghorror.com/doing-terrible-things-to-your-code/)* by Jeff Atwood for good testing tips.

EDIT: I may not have emphasized this enough, but *trust the CI*. The purpose here is to test the code outside of the automatic unit tests; in short, you're testing what the CI cannot test. If this doesn't apply, and there is truly nothing *to* manually test, don't waste your time.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#principle-4)Principle #4
==============================================================================================

Commenting matters. MousePaw Media developed and uses the [Commenting Showing Intent standard](https://standards.mousepawmedia.com/csi.html), which means that roughly every logical statement should have a comment describing the programmer's intention for it. (See my article *[Your Project Isn't Done Yet](https://dev.to/codemouse92/your-project-isnt-done-yet)* for an explanation of why intent comments are important.)

Assuming you're working on a project that follows this convention, if you don't see an intent comment, you should request one to be added into the code. Then look for it before you approve. (If the project *doesn't* follow the CSI standard or something similar, consider proposing adoption of the standard for all future code.)

In regards to comments, it isn't enough just to have *something* there. Intent comments should actually describe *intent*. You should address any of the following problems:

1.  The intent comment doesn't match the logic. This indicates that the comment, code, or both are wrong. We've caught *many* potentially nasty bugs this way!

2.  The intent comment doesn't make sense. If the comment is confusing, it's as useful as no comment at all.

3.  The intent comment has major typos. Grammar and spelling are important to meaning, especially when one doesn't know the audience. Will the next reader be English-as-a-Second-Language? Dyslexic? Just learning to code? Proper English is always easiest to decipher.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#principle-5)Principle #5
==============================================================================================

Review temporary code as strictly as production code. It can be shocking just how often temporary "patch" code and workarounds make it into production, and how much of it is never actually replaced. This is just a reality of real-world programming. Thus, we should hold *all* code to the same standards and expectations.

In other words, even if the code's solution isn't ideal, the implementation should be clean, maintainable, and reasonably efficient.

To put it yet another way, there is never an excuse for kludgy code.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#principle-6)Principle #6
==============================================================================================

Consider how the code will work in production. Design is important, and integration matters. How will this code function in the real world? How will it handle bad input and user error? Will it play well with the rest of the code base? In short, be demanding of the code. (See Principle #3.)

This ties in with Principle #5. It can be tempting to request (as the author) or grant (as the reviewer) grace for "unfinished" code, but therein lies a serious danger of shipping broken code!

If the code *is* broken, the user generally should not have easy access to it! An unfinished class may be marked as "experimental" and documented as such, thereby preventing a user from mistaking it for finished code. By contrast, a broken function should not be exposed in a non-experimental class.

Another way to look at this matter is this: if the code was shipped to end-users on the next commit, it may be *functionally incomplete*, but it should NOT be *broken*. In reality, this goal is rarely achieved, but the perspective will help prevent bad code from landing to your repository.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#principle-7)Principle #7
==============================================================================================

Check documentation, tests, and build files. Good code doesn't just include code, it includes all of the trappings that go with it. (Again, see *[Your Project Isn't Done Yet](https://dev.to/codemouse92/your-project-isnt-done-yet)*.

At MousePaw Media, we expect that every revision will contain all of the following:

-   Tests covering the new code. Review these as strictly as you do the code itself, to ensure the test will fail if there is a problem.

-   Documentation for the new code. The best documentation is written in tandem with the code itself. Don't accept documentation *later*; it should be present within the revision itself!

-   Build files updated for the changes. Any time code files are added, removed, or renamed, the build files need to reflect those changes. Similarly, if any dependencies have changed, the build files should reflect that too. This is one more reason why you should build the changes yourself (Principle #3).

-   README changes. The markdown files, such as `README.md`, `BUILDING.md`, `CHANGELOG.md`, and so forth should reflect the latest changes. In reality, these rarely need to be changed, but you should be sure they're up-to-date.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#principle-8)Principle #8
==============================================================================================

When reviewing, keep priorities straight when making suggestions.

Code should be...

1.  Functional first,

2.  Clean and maintainable second, and

3.  Optimized third.

Code should ultimately achieve all three, but the order is important. If the code doesn't work, don't worry about style yet. Similarly, if the code is broken or poorly styled, optimization is only going to make things worse.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#principle-9)Principle #9
==============================================================================================

Follow up on reviews. After suggesting changes, you should be prepared to review it again. Ensure the necessary changes were made, and any problems you found were reasonably resolved.

Be sure to devote just as much attention to the follow up review as to the original one! Apply all ten principles anew.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#principle-10)Principle #10
================================================================================================

Reviewing can be daunting, so it helps to remember that reviewers are not perfect! Issues may slip past you, bugs may evade detection, performance flaws may make it to production...in short, broken code happens!

If you are not familiar with the code or concepts, you may want to request that an additional reviewer provide feedback, but don't shy away from doing the review yourself! Ultimately, four eyes are always better than two.

If you do realize you've made a mistake in a review, the best thing you can do is own up to it. Raise a concern on the post-commit review system if appropriate, or else file an issue/bug report.

EDIT: One Twitter commentator pointed out another angle on this principle: keep your ego out of reviews! This isn't an arena for oneupmanship. If you go in with the intent to show your brilliance, tear down another coder, or otherwise beat them over the head with your experience, do everyone a favor and don't bother reviewing the code at all. A code review with ego attached is far worse than no review at all.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#one-thing-more)One Thing More...
======================================================================================================

At MousePaw Media, we actually have a *strict* revision checklist. Everything is expected to meet all these goals. Obviously, this is tailored to our particular project, but you might be able to take some notes for it and come up with your own.

When we first developed this checklist, I hadn't yet found *[A Code Review Checklist Prevents Stupid Mistakes](https://dev.to/bosepchuk/a-code-review-checklist-prevents-stupid-mistakes-o6)* by Blaine Osepchuk, but it's well worth a read!

So, for us, every revision must...

(1) Accomplish the feature(s) it was designed to accomplish.

We follow a rule of one-feature-per-revision. In some cases, the feature itself may be dropped, and only bugfixes and/or optimizations landed instead.

(2) Have merged all changes from `master` into itself, and all conflicts resolved.

(3) Have binaries and unnecessary cruft untracked and removed. (Keep an eye on `.gitignore`!)

(4) Compile and run properly - this should be confirmed via the CI system (Harbormaster/Jenkins in our case).

(5) Be free of compiler errors and warnings.

To the aim of #5, we compile all our C++ code with with `-Wall -Wextra -Werror`).

(6) Be Valgrind pure (no memory leaks detected).

Once again, this is specific to our C and C++ code, but many languages have equivalents.

(7) Comply with the company's (or project's) Coding and Technical standards.

(8) Be free of linter errors.

We use `cppcheck` for C++, and `pylint` for Python.

(9) Be fully CSI commented.

Once again, see our [Commenting Showing Intent standard](https://standards.mousepawmedia.com/csi.html).

(10) Have an up-to-date build script (CMake in our case) if relevant.

(11) Contain relevant tests.

(12) Have a Test Plan to aid reviewers in making sure your code works.

(13) Be reviewed, built, tested, and approved by at least one trusted-level reviewer.

(14) Have up-to-date (Sphinx) documentation, which compiles with no warnings.

We get the best results by *not* putting this off until later!

(15) Have all reviewer comments processed and marked "Done".

This is a side-effect of our particular review tool, Phabricator Differential, but you might request that all suggested changes be read and considered.

[](https://dev.to/codemouse92/10-principles-of-a-good-code-review-2eg#in-summary)In Summary
===========================================================================================

These principles aren't actually new to MousePaw Media's workflow - we've been implicitly following them for some time - but I hope that by crafting this guide, we can achieve a more consistent application of them.

What code review principles does your project or organization follow?

EDIT: Please read the comments section on this, especially the superb comment by edA-qa mort-ora-y (and the conversation precipitating thereof). There are some valuable notes and alternative views on this topic that warrant consideration.)
