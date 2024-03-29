Giving and Receiving Great Code Reviews
=======================================

[#codereview](https://dev.to/t/codereview)[#code](https://dev.to/t/code)[#mentors](https://dev.to/t/mentors)[#career](https://dev.to/t/career)

Taking part in code reviews has been one of the most interesting learning experiences in my career. I've done some really dumb stuff and I've learnt a whole lot with the over 400 reviews I've participated in the last two years. They can teach you so much about yourself and your code and I'm excited to tell you more about them today.

So what is a code review, *really*? Code review is a time to discuss and debate code that is going to be owned by the team going forward. A member, or members of the team will write the code, and the rest of the team, or a subset will determine if it's at a standard such that'll be a good value add to the codebase.

On a more micro scale, code reviews is an abstract concept for a process of reviewing both approach and code as you complete a task. In my mind, there are two distinct phases of code review.

So you've spent a few hours or days reading the existing code, understand what's there, how the data flows and the what changes you'll need to make. You're probably about 20% in at this point. From here you propose your changes to a senior. Firstly, they'll respect the work you've put in before bothering them (their time is a bit precious sometimes), secondly with your knowledge, and knowledge they'll also likely have, they'll be able to have a discussion on the approach with you, perhaps suggesting minor tweaks, or even asking you to start again (sorry, but it happens to all of us).

Once that's decided, it's time to write your code. This brings you to the main code review, you're about 90% done at this point and it's really just a matter of agreeing on code design and a few other things.

[](https://dev.to/samjarman/giving-and-receiving-great-code-reviews#as-the-submitter)As the Submitter
-----------------------------------------------------------------------------------------------------

So let's talk about the key tips for creating great pull request (PR), which is the modern mechanism for reviewing code.

The first is to tell a story with your PR. You've spent all your time thinking about it, but the reviewer has not. So tell them your thought process and then describe the logical series of steps you took to implement that. As a reviewer, I'm looking at two things; your commit log and your PR description.

Your commits should be a series of steps taken. All code should be paired with its respective unit test and each commit should follow the following rules:

1.  Separate subject from body with a blank line

2.  Limit the subject line to 50 characters

3.  Capitalize the subject line

4.  Do not end the subject line with a period

5.  Use the imperative mood in the subject line

6.  Wrap the body at 72 characters

7.  Use the body to explain what and why vs. how

Further details can be found on [Chris Beams blog](https://chris.beams.io/posts/git-commit/). You should read them.

So once you have your logical commits, with no "merge from master" or "fix thing" or "trying something fbdifha ahhh" commits, we can start reviewing. PS, using interactive git rebasing and soft git resetting might help you once you're ready to start preparing your commits.

Now, the PR description. In my opinion, this should contain a few things

1.  A link to the original issue you're solving (eg GitHub issue or JIRA ticket or other)

2.  An overview of the thinking process

3.  How you went about testing this locally (eg "I ran this service and the X service and used cURL to confirm the new request behavior was working as expected")

4.  Anything you think you might break with this PR (but you've checked it hasn't)

5.  Anything you'd like the reviewers opinion on specifically (eg class names, time complexity of code, etc)

Once you've done that, the reviewer is able to quickly get up to speed on the code and focus on the quality and impact of the code. Approach a member of the team, perhaps two and ask for code reviews. Try to make sure it's someone who hasn't helped you too much throughout the coding process, so you have a fresh set of eyes on the code.

Finally, before you submit your review, do your own. Check, do my commits look right? Have I left in any debugging code? Have I left in any test keywords (I always leave in rspec's focus). Does the code diff look like I expect it to? This 90 second check can save the reviewers a tonne of confusion.

[](https://dev.to/samjarman/giving-and-receiving-great-code-reviews#as-the-reviewer)As the Reviewer
---------------------------------------------------------------------------------------------------

The most important point I have to make for code reviewers is that reviewing code is work. It's value add to the company, and while it might not be *your*task, it's still just as important. The team has decided that the work being completed by the submitter is important enough to be done right now, so you should treat it as such and really own it.

So, take your time with code reviews. It's okay to spend many hours on reviewing code, and it's okay to call it out as what you're working on. Rushed code reviews will only come back to bite you in the future. You maybe be the one working on that area next!

Be sure to click through the commits and PR description for more context before you start reading code. If the reviewer has questions, tend to those as well, and take your time. If you're unsure the code will actually work, check out the branch and try follow the steps to reproduce the testing. Remember; *if in doubt, check it out*.

Now, if you find yourself nitpicking over style, please, ask yourself, why didn't the lint checker catch this? Is this a new rule that can be added, or is this something I can educate the coder about? Remember code reviews aren't really about things that can be automatically checked by tools such as [SwiftClean](http://www.swiftcleanapp.com/), [Credo](https://github.com/rrrene/credo), [FindBugs](http://findbugs.sourceforge.net/), [Rubocop](http://batsov.com/rubocop/) or [StyleCop](https://github.com/StyleCop), so make sure your code has those and it runs on your CI, failing the build if any violations are found.

Now, it's possible to have a few iterations of this code review phase. New changes need to be re-reviewed in the context of the existing changes, and that may prompt more required changes. Be patient and encourage the submitter to be patient too. Code review is also a great time to "take it offline" and encourage a whiteboard or pair programming session to chat through any major flaws in their code or do some coaching/mentoring about something. Ideally, code reviews from the same person shouldn't ever include the same flaws.

So that's code review. In summary, as a submitter, plan, tell the story, and use the review as a learning experience. As a reviewer, slow down, check carefully, automate as much as you can and take the opportunity to improve your team.

Good luck! Any questions? I'd love to hear them!
