# **The (written) unwritten guide to pull requests**

July 25, 2019

Code review is a very important part of the software development cycle. On Bitbucket and other source code management systems, pull requests are used to review code on branches before it reaches master. Code review is also one of the most difficult and time-consuming part of the software development process, often requiring experienced team members to spend time reading, thinking, evaluating, and responding to implementations of new features or systems.

It&#39;s no surprise that endless &quot;in review&quot; columns in agile boards is one of the most common issues raised by software teams (including at Atlassian!) during sprint retrospectives.

To help your software development team empty those &quot;in review&quot; columns quickly, here are some guidelines for your pull requests from a variety of different developers at Atlassian.

![](RackMultipart20201228-4-1vidvwv_html_8cc911174bef905d.png)

\&lt;img loading=&quot;lazy&quot; width=&quot;2038&quot; height=&quot;1412&quot; src=&quot;https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-5.55.25-pm.png&quot; alt=&quot;An example of &amp;quot;in review&amp;quot; columns in an agile board&quot; class=&quot;wp-image-45607&quot; srcset=&quot;https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-5.55.25-pm.png 2038w, https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-5.55.25-pm-300x208.png 300w, https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-5.55.25-pm-600x416.png 600w, https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-5.55.25-pm-768x532.png 768w, https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-5.55.25-pm-1536x1064.png 1536w&quot; sizes=&quot;(max-width: 2038px) 100vw, 2038px&quot; /\&gt;

_I&#39; __m sure the size of that_ _&quot;__ in review__&quot;_ _column is familiar with many-a-team._

## **Reviewing pull requests is hard**

First, let&#39;s admit it: reviewing pull requests is really hard. As a reviewer, it&#39;s your responsibility to make sure that the code is correct and of high quality before it gets merged into master. You are expected to do that by looking at a diff and list of files changed. You have to understand what the pull request is trying to achieve, what approach is being taken, what&#39;s going on, and how all these files fit together – enough that you could potentially suggest an improvement. You may have to be on the lookout for typos or style problems. That&#39;s a LOT of stuff a reviewer needs to do, especially in a large pull request!

How can we make our pull requests easier for our reviewers?

Let&#39;s put on our product management hat. If pull requests are a product, then reviewers are our customers. We want our customers to &#39;buy&#39; our pull requests by approving them so we can ship quickly and empty that review column. If we are to manage this product well, one thing we need to do is understand our customers and market. It&#39;s pretty simple, really. Since most of us pull request authors have likely been reviewers already, simply put yourself in the shoes of the reviewer and ask, &quot;How could this be easier for me?&quot;

## **Make smaller pull requests**

Making smaller pull requests is the #1 way to speed up your review time. Because they are so small, it&#39;s easier for the reviewers to understand the context and reason with the logic. Now, you may be thinking:

But Blake, my issue just exploded in complexity after I started working on it.

Trust me, I&#39;ve been there. It&#39;s really easy to throw yourself into finding the solution to the problem you&#39;re working on and lose focus on the bigger picture. Unfortunately, in my experience, solving the issue usually represents a surprisingly low portion of the time spent between ticket creation and release to customers. Review, quality assurance, and the release process all take time. Spending a bit more time breaking down the problem while you&#39;re actually problem-solving is worthwhile, especially when your team has endless review columns.

I have no way to tell whether a pull request is going to be big until I start on an issue, at which point it&#39;s usually too late.

It&#39;s easy to make big pull requests. It&#39;s difficult to make small, logical ones that are quick to review, push, and achieve velocity with. On my team, we are experimenting with small, time-boxed spikes on issues we pick up to see if we should break them down any more before pushing any code. We&#39;ll see how that goes, but in the meantime, it&#39;s definitely worth time breaking down your tickets or pull requests before you commit them in one massive push.

![](RackMultipart20201228-4-1vidvwv_html_403b87750889687d.gif)

\&lt;img loading=&quot;lazy&quot; width=&quot;1710&quot; height=&quot;852&quot; src=&quot;https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-6.13.40-pm.png&quot; alt=&quot;An example of a ticket&quot; class=&quot;wp-image-45608&quot; srcset=&quot;https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-6.13.40-pm.png 1710w, https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-6.13.40-pm-300x149.png 300w, https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-6.13.40-pm-600x299.png 600w, https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-6.13.40-pm-768x383.png 768w, https://3kllhk1ibq34qk6sp3bhtox1-wpengine.netdna-ssl.com/wp-content/uploads/2020/02/screen-shot-2020-02-11-at-6.13.40-pm-1536x765.png 1536w&quot; sizes=&quot;(max-width: 1710px) 100vw, 1710px&quot; /\&gt;

## **Write useful descriptions and titles**

Writing a useful description in the &quot;details&quot; section of your pull request can almost be as effective as making a smaller pull request! If I do make a large pull request, I&#39;ll make sure to spend a lot of time making a really helpful description. The most helpful descriptions guide the reviewer through the code as much as possible, highlighting related files and grouping them into concepts or problems that are being solved. This saves the reviewer a lot of time because they don&#39;t have to read every file to try and group them up and identify related concepts. After that, it&#39;s a lot easier to reason about and review your approach. The pull request author is the best person to do this since they made these files in the first place, and have all the details fresh in their minds. Similarly, a useful summary title (instead of just the issue key) makes it clear to the reviewer what&#39;s being solved at a high level, which takes off one extra step for the reviewer. At the end of the day, both of these things give the reviewer more context around the change that&#39;s happening.

## **Have on-point commit messages**

&quot;Addressed PR feedback:&quot;  -\&gt; a very common, but not-so-useful commit message.

I don&#39;t expect everyone to have every line of their Git commit messages down to a strict 72-character limit, (although the first 50 characters are useful as a summary), but a good commit message can help improve a code reviewer&#39;s experience. First, they can make Bitbucket&#39;s auto-generated pull requests more useful, especially for smaller pull requests. Good commit messages can also provide a nice bullet-point-like summary of the code changes as well, and it helps reviewers who read the commits in addition to the diff.

I&#39;m a bit guilty of lower-quality commit messages. That said, commits are very much at the code-level, and should be about the code changes. A pull request, on the other hand, though it is code-focused, requires a higher-level, architectural understanding of the change. A high-level summary and understanding of the problem is very useful for people looking back through a repo&#39;s history in addition to reading the details of the individual code changes. For this reason, I&#39;m very much a proponent of putting a Jira issue key in every commit message, so no matter where a user finds a commit message from, there&#39;ll always be a trail back to the pull request. This also helps soften the blow of lower-quality commit messages.

Even if you have completely on-point commit messages, I still believe in writing a good description in the pull request over only using the auto-generated commit log. As I said before, commits are very much at the code-level while code review requires a higher-level understanding of the change, and that&#39;s hard to achieve with a commit message log alone.

A colleague gave me really nice summary of how to think while writing commit messages:

Commit message should talk about WHAT changed, and WHY. Not HOW – how is the diff, and you don&#39;t need to repeat it.

## **Add comments on your pull request to help guide the reviewer**

Have you simply re-indented lines in one file? Is a particular file the &quot;main bulk&quot; of your change? Is a file related to, or coupled with, another in the same pull request? Consider leaving a comment inline, at the top of the file, to let the reviewer know. These help the reviewer navigate your pull request.

Even better, it&#39;s possible to create a pull request with no reviewers allowing you to review it yourself and write comments pointing out the interesting bits before anyone else sees the code.

It&#39;s worth noting that pull request comments should not be used to explain your code. If you find yourself explaining your own code in a pull request comment, consider making it an actual, in-code comment instead. These comments are only for helping the reviewer navigate your pull request.

## **Make it visual**

Add some screenshots for your front-end changes! Screenshots simply make the job for the reviewer much easier. It&#39;s easier to reason about front-end changes when you can visually see what&#39;s been changed in the pull request. If you&#39;re feeling extra generous, add a GIF or video of you using the feature (potentially in multiple browsers, if that&#39;s important) to add some extra validation for your UI changes.

Also, consider adding your designers to pull requests for front-end changes. They can often spot visual quirks, as well as copy mistakes, earlier in the process thanks to the screenshots!

## **Wrapping up**

These are just some of ways to write pull requests to improve the pull request experience for reviewers around your company.

If you start thinking of a pull request as a product, with the author as the seller, and reviewers as customers, then that helps us understand our customer in order to &quot;sell&quot; our pull request more effectively and get faster approvals.

Though this is how I think about pull requests, I want to emphasize that these are just guidelines, not hard and fast rules. Please feel free to tweet @atlassian with your own techniques for keeping your PR column under control and share your pull request experiences – I&#39;d love to hear how your team handles code review!

Hopefully, together we can create better pull request and code review experiences for everybody.

Did you like this article? Then you might love reviewing our resources in our git tutorial site.

[Read more about git](https://www.atlassian.com/git/tutorials/making-a-pull-request/)
