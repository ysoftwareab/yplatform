# **What does code readability mean?**

Programmers complain about readability and talk about bad code and unclean code, and the difficulties they run into trying to understand and maintain that code. What do we mean by readability? What makes code unreadable?

_Russian translation of this article available thanks to Vlad Brown:_

[Что означает читаемость кода?](http://howtorecover.me/cto-oznacaet-citaemost-koda)

## **Reframing the problem**

I hear programmers say that some code &quot;is unreadable.&quot; I read articles and books about readability and maintainability. What does that mean? Programmers usually attribute _readability_, or more often the lack of, to the code itself. But, like beauty, readability lies in the eyes of the beholder. When we say that some code &quot;is unreadable&quot; we actually mean one or more of:

- I can't read the code because I don't have sufficient experience or expertise (with the language or domain).
- I haven't spent enough time trying to read and understand the code (&quot;it's not obvious&quot; or &quot;it's not intuitive&quot;).
- I don't have much interest in understanding this code, I prefer to rewrite it in my own style.
- The code offends my sense of aesthetics; I would write it differently.
- The original programmer didn't know how to write code.
- The code appears to violate some principles or patterns I believe in.

Simply reframing the statement &quot;this code is unreadable&quot; as &quot;I can't read this code&quot; puts the problem into perspective.

By analogy, plenty of people find reading Homer, Shakespeare, or Nabokov difficult and challenging, but we don't say &quot;_Macbeth_ is unreadable.&quot; We understand that the problem lies with the reader. We may not have sufficient experience with the language and idioms. We may not have enough historical and cultural context (similar to lacking domain expertise when looking at software). We may not have the patience or desire to invest time learning how to read a challenging book. Wikipedia articles and _Cliff __'__ s Notes_ exist to give tl;dr versions of books to people who can't or don't want to read the original. When we observe this tendency in other (non-programming) contexts we may interpret it as laziness or short attention span. When we react this way to code we blame the code and the original programmer.

When I first read Knuth's _The Art Of Computer Programming_ as a teenaged amateur programmer I found Knuth's math-heavy analysis of algorithms hard to understand. I didn't think Knuth _doesn __'__ t know how to write_, or that his examples and explanations needed refactoring and dumbing-down. I thought I needed to learn more about the math and analytic techniques so I could competently understand the books. As my comfort with the math improved Knuth's previously unreadable books yielded a lot of great information.

I recently told a programmer friend that, in my experience doing a lot of maintenance work on legacy systems, all code yields to maintenance with enough study. I get more concerned about the time _I require_ to understand the code, and the risks when making changes to it. Good code should yield to understanding, and present fewer risks when making changes. Those qualities come from the skill of the original programmer, and the constraints imposed at the time they wrote the code. The original programmer may have tried to predict future maintenance and write the code in a way they think of as clear and readable, but doing that requires making assumptions and predictions about unknown future requirements, and unknown future maintenance programmers. Programmers can easily get carried away making those assumptions, adding complexity and generality and getting farther away from the requirements, without actually making the code more readable or maintainable.

## **Programmer bias**

Programmers usually think that they should focus on _writing_ code. Reading code, especially someone else's code, seems like grunt work, a necessary evil, often relegated to junior programmers in maintenance roles. Reading code and figuring it out does not feel like a creative or even productive activity.

I have personally witnessed (more than a few times) professional programmers dismiss working, production code as &quot;unreadable&quot; and &quot;unmaintainable&quot; after looking at it for just a few minutes. Their objections usually come down to aesthetics: &quot;I hate PHP.&quot; &quot;The code uses tabs instead of spaces and looks bad in my editor.&quot; &quot;The code wasn't written with classes and objects.&quot; They haven't spent enough time to understand the system, or learning enough about the business domain to read the code in context (like someone unaware of ancient Greek history dismissing _The Iliad_).

Programmers looking at code they don't understand or don't like can find examples of sacred principles and so-called best practices violated: &quot;This breaks the Single-Responsibility Principle.&quot; &quot;This looks like a DRY violation.&quot; &quot;Globals are a code smell.&quot; Then they propose rewriting the system, or maybe rewriting pieces of it in their preferred language, idiom, and style (often erroneously called &quot;refactoring&quot; because that sounds like a technical thing to the customer or boss).

_Whenever I have to think to understand what the code is doing, I ask myself if I can refactor the code to make that understanding more immediately apparent._ _– Martin Fowler._

_Any fool can write code that a computer can understand. Good programmers write code that humans can understand._ _–_ _Martin Fowler_

All respect to Martin Fowler, but those quotes illustrate my point. My experience leads me to _expect_ I will &quot;have to think&quot; to understand unfamiliar code. How hard I have to think matters, but I don't expect to immediately understand non-trivial code at a glance, even with my decades of experience. After I understand the code I may think I can write it more clearly and refactor it, or I may feel like I learned something new from the code and leave it alone. I don't think code has to yield to understanding at a glance, especially considering the very wide range in skills and experience among programmers. And I don't call other programmers fools if I don't immediately understand their code. &quot;Other humans,&quot; or even other programmers, includes far too many people across a vast skill and experience spectrum to make &quot;write code that humans can understand&quot; a meaningful goal. If good authors wrote books that everyone could instantly understand we'd have nothing but _The Hungry Caterpillar_ and _Puppy Peek-a-boo_ on our bookshelves.

_Just because people tell you it can __'__ t be done, that doesn __'__ t necessarily mean that it can __'__ t be done. It just means that they can __'__ t do it._ _–_ _Anders Hejlsberg_

That applies just as much when _reading_ code as it does when _writing_ code. Remember that the next time you or someone you work with declares some code &quot;unreadable&quot; and &quot;impossible to maintain.&quot;

_The true test of intelligence is not how much we know how to do, but how to behave when we don __'__ t know what to do._ _–_ _John Holt_

## **Simple vs. dumbing down**

This came across my Twitter feed a while back:

_Good code is simple. Code reviews are a great way to train teams to write simple code. Don __'__ t be afraid to say_ _&quot; __this is hard to understand.__&quot; –_ _Eric Elliott_

&quot;Good code is simple&quot; doesn't actually say anything. My many years of programming experience and business domain expertise gives me a very different idea of &quot;simple&quot; than someone with less experience and no domain expertise looking at some code for a few minutes. What we call &quot;simple&quot; depends on our experience, skills, interest, patience, and curiosity. Programmers should say something when they don't understand code, but rather than saying &quot;this code sucks&quot; they should say &quot;I can't understand this code – yet.&quot; That puts the focus on the person who struggles to understand rather than on the code. I agree that code reviews improve code quality and team cohesion, but whether that translates to &quot;simple&quot; code depends on the programmers. Programming teams usually converge on common idioms and style, and that make programming together easier, but that convergence doesn't mean the code will look readable to an outsider looking at it six months later.

Does that mean all programmers should dumb their code down so even beginners with no domain expertise can understand it at a glance? Should we strive to satisfy the _Shakespeare for Dummies_ demographic? When faced with code I don't understand I first question my own skills and patience, and if I have sufficient motivation (like a paying customer) I will spend time studying the code to improve my ability to understand it. I may have to look at language or framework documentation, or experiment with the code to figure out how it works. When I understand the code I may think that I know a simpler or more clear way to express it, or I may think that the code only presented a challenge to me because I didn't have the skills or knowledge or right frame of mind. In my experience figuring code out takes significant time and effort, but when I get through that I don't usually think the code has fatal readability flaws, or that the original programmer didn't know how to write code.

_Controlling complexity is the essence of computer programming._ _–_ _Brian W. Kernighan_

Complexity in programming happens at many levels, from the overall system architecture to the choice of variable names and flow control idioms. With experience and reflection programmers should develop a sense for unnecessary complexity, and learn how to control it in their own work. The presence of apparent complexity does not always mean the code sucks or resists reading; some problems prove complicated to implement and the resulting code will require some study to understand.

## **Readability performance art**

We think of programming as a process of using and writing abstractions. When the abstractions map to the requirements in a reasonably obvious way, the code usually makes more sense. When the abstractions come from gratuitous application of &quot;design patterns&quot; or &quot;best practices&quot; for their own sake, the code gets harder to understand because you have to mentally follow disconnected chains of abstractions: the business requirements and the software implementation.

In the olden days programmers wrote code that few other programmers would see – the other members of their team or group, their mentors, maybe an analyst or project manager. Now we have open source and people posting their code in blogs and in Stack Overflow questions. Programmers, prone to investing their ego in their code, worry about criticism from a lot of people they don't know. Slurs about competency abound in programmer forums. Code samples out of context get critiqued and subjected to stylistic nit-picking. That process can prove helpful for programmers with thick skins who can interpret criticism as either useful mentoring or useless insults. Less experienced programmers can get misled and brow-beaten. Public code reviews create a kind of programmer performance art, when programmers write code to impress other programmers, or to avoid withering criticism from self-appointed experts.

_The key to efficient development is to make interesting new mistakes._ _–_ _Tom Love_

It helps to discover your own mistakes or have someone point them out to you in a helpful way. That's how we learn to program, and learn how to write better code. I don't think it helps to write code with the prospect of public humiliation in the back of your mind.

_Programming is a creative art form based in logic. Every programmer is different and will code differently. It __'__ s the output that matters._ _–_ _John Romero_

_The most important property of a program is whether it accomplishes the intention of its user._ _– C.A.R. Hoare_

Better programming comes through practice, study (from books and other code), and mentoring. It doesn't come from trying to blindly adhere to rules and dogma and cargo cults you don't understand or can't relate to actual code.

## **How to write readable code**

When I started programming back in the mid-1970s, one of my mentors gave me a copy of _The Elements Of Programming Style_ (Kernighan and Plauger, 1974). From that book I learned that some techniques often worked better than others, I learned about language idioms, naming variables and functions, and other stylistic and aesthetic considerations that have stuck with me. From there I read quite a few other books about &quot;good&quot; programming, above the level of style and aesthetics. And I read a lot of code, some I understood and a lot that I didn't (or didn't understand right away). Like the English writing classic _The Elements Of Style_, Kernighan and Plauger focus mainly on coding techniques and style, not on the larger issues of system design, module decomposition, cohesion and coupling, and requirements gathering. _The Elements Of Programming Style_ serves as a starting point, an introduction to developing a style that will make your code expressive, concise, and easier to read. Similarly _The Elements Of Style_ advises &quot;Omit needless words&quot; and cautions writers away from passive voice and too many adjectives.

_We build our computer (systems) the way we build our cities: over time, without a plan, on top of ruins._ _–_ _Ellen Ullman_

Well, yes, and we tend to like many of our cities. I agree with Ellen Ullman that software development often follows a more haphazard path than we like to tell ourselves. That just means we can't reliably predict the future, and we don't always have the resources or will to tear things down and start over. The genre of programming aphorisms brims with statements like this, which only make sense if we believe in a &quot;right way&quot; to develop software, a set of hard, proven principles that lead to &quot;good&quot; code, and that any code we don't immediately understand must have inherent bad-ness, or indicates a fool at the keyboard.

Programmers seem to believe in a realm of beautiful, readable, easy-to-maintain code that they haven't seen or worked with yet. They seem to think that other programmers get the time and support to write perfect, clean, tested code. That mythical realm doesn't exist. All code baffles and frustrates and offends a significant subset of programmers. All software gets developed under time, budget, management, requirements, and skill constraints that prevent doing anything perfectly. We should keep those constraints and limits in mind when we look at code and immediately conclude the code resists understanding, or that only fools would have produced such software.

_No one in the brief history of computing has ever written a piece of perfect software. It __'__ s unlikely that you __'__ ll be the first._ _–_ _Andy Hunt_

How do you learn to write readable code? Like learning to write readable English, you have to read a lot. Spend the time to try to understand code beyond superficial qualities that don't match your biases and preferences. Emulate code you find especially readable. Read some of the popular well-reviewed books on programming style and code quality to get some benefit from more experienced programmers. Try to describe why code resists easy reading or maintenance in concrete terms, try your alternatives (refactorings), make sure they work, get other programmers to _constructively_ review your code and listen to them.

_Thanks to the Programming Wisdom @CodeWisdom Twitter feed for the quotes in this article._
