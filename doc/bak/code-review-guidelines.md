# **Code Review Guidelines for Humans**

Posted on Jul 31, 2018. Updated on Jun 12, 2020

Code reviews are powerful means to improve the code quality, establish best practices and to spread knowledge. However, code reviews can come to nothing or harm interpersonal relations when they are done wrong. Hence, it&#39;s important to pay attention to the human aspects of code reviews. Code reviews require a certain mindset and phrasing techniques to be successful. This post provides both the author and the reviewer with a compass for navigating through a constructive, effective and respectful code review.

![](RackMultipart20201228-4-1129e6b_html_144f559e90c332ef.png)

## **TL;DR**

_Code review guidelines for doing code reviews like a human._

## **Code Reviews Guidelines For the Author**

For you, as the author (or &quot;developer&quot;, &quot;submitter&quot;), it&#39;s important to have an **open and humble mindset** about the feedback you will receive.

## **Be Humble**

_To err is human. Everybody makes mistakes._

We are humans after all. And humans make mistakes. That&#39;s normal. So as long as software will be written by humans, it will contain mistakes.

This doesn&#39;t mean that you should code carelessly or stop writing tests. But this mindset will take away the fear of mistakes and create an atmosphere where making mistakes is accepted and admitting them is desired. This, in turn, is important for criticism during a code review to be accepted. Otherwise, you may end up in endless justifications and rejections because mistakes may be seen as something forbidden and have to be kept hidden. This prevents the required openness for feedback.

_Making mistakes is accepted and admitting them is desired._

The key takeaway here is: **Be humble**. Mind that everybody&#39;s code can be improved. You are not perfect. So you have to accept that you will make mistakes. It doesn&#39;t matter how good you are, you can still learn and improve. Don&#39;t consider yourself as infallible and don&#39;t infer your professionalism and reliability as a software developer from infallibility and flawlessness. Admitting mistakes shows that you are professional, honest and after all a human being.

Moreover, I believe that the behavior of the team manager is crucial here. He is the role model for the whole team and should demonstrate a error culture by admitting mistakes in the public. And he should also call them &quot;mistakes&quot;.

## **You Are Not Your Code**

_You are not your code._

Repeat after me: **You are not your code**. Criticism on your code is not a criticism on you as a human. Don&#39;t connect your self-worth with the code you write. You are still a valuable team member even if there are some flaws in your code.

In the end, programming is just a skill. It improves with training - and this improvement never stops.

## **You Are on the Same Side**

&quot;_Criticism is almost never personal in a professional software engineering environment —_ _it&#39; __s usually just part of the process of making a better product__&quot;_. Fitzpatrick, Collins-Sussman: [Debugging Teams](https://www.amazon.com/gp/product/1491932058/ref=as_li_tl?ie=UTF8&amp;camp=1789&amp;creative=9325&amp;creativeASIN=1491932058&amp;linkCode=as2&amp;tag=blogphilippha-20&amp;linkId=11df23d70998637d042bc6a46a4e6d1f) ![](RackMultipart20201228-4-1129e6b_html_1d7f9975b05d6279.png), page 16

_You are on the same side_

When receiving feedback from the reviewer, always keep in mind that you and the reviewer are on the same side: You want to create a great product.

## **Mind the IKEA Effect**

The IKEA effect is a cognitive bias in which consumers place a disproportionately high value on products they partially created. [Wikipedia](https://en.wikipedia.org/wiki/IKEA_effect)

The effect was demonstrated by the following experiment: Two groups should price the value of IKEA furniture. One group got already assembled furniture, the other group had to assemble them first. The results showed that the second group was willing to pay 63 % more than the first group.

_The IKEA effect let us place more value on things (furniture, code) we have created by ourself._

Applied to software development this means: We place more value into code that we have written. It might be harder for us to accept changes or removal of code that we have created. It&#39;s important to be aware of this bias when we receive feedback because we might be influenced by the IKEA effect.

## **New Perspectives On Your Code**

_A code review provides new perspectives on your code_

Every developer has a different background, assumptions, knowledge, and experiences; and so does the reviewer of your code. It&#39;s totally natural that they see your code differently than you do. Moreover, they are not so familiar with the domain or concrete functionality that kept you busy the last days. That&#39;s great because this reveals code that was clear for you, but not for the reviewer.

_ **// Reviewer: &quot;When does this happen?&quot;** _

**if (article.state == State.INACTIVE) {**

**}**

_ **// Implicit knowledge here!** _

vs.

_ **// Reviewer: &quot;Ah, the state means out-of-stock&quot;** _

**boolean articleIsOutOfStock = article.state == State.INACTIVE;**

**if (articleIsOutOfStock) {**

**}**

_ **// make knowledge explicit by using expressive names** _

So code reviews **reveal the implicit knowledge** that is not expressed in the code yet because it appears natural for you. We are avoiding a tunnel vision.

But the best point here is: You don&#39;t have to be angry with yourself as you often simply _ **can** __ **&#39;t** _ **see those issues**. You only have one perspective. So just be thankful and embrace the opportunity to get a different perspective on your code. It&#39;s so valuable.

## **Exchange of Best Practices and Experiences**

_During a code review, the author and reviewer are exchanging best practices, experiences, tips, and tricks._

You and the reviewer are not only talking about your code - you are exchanging best practices and experiences. Code reviews are a great medium to establish and internalize good coding styles and best practices. And the exchange works in both directions. So consider code reviews as a valuable source of knowledge and an opportunity to learn.

## **Code Reviews Guidelines For the Reviewer**

For you, as the reviewer, it&#39;s important to pay attention to the way you are **formulating your feedback**. The phrasing is extremely crucial for your feedback to be accepted.

## **Use I-Messages**

_Increase the acceptance of your feedback by using I-messages_

Wrong: &quot; **You** are writing cryptic code.&quot;

Right: &quot;It&#39;s hard **for me** to grasp what&#39;s going on in this code.&quot;

Always formulate your feedback from **your point of view** by expressing your **personal** thoughts, feelings, and impressions. Why? Because it&#39;s hard for the author to argue against your personal feelings since they are subjective.

In contrast, You-messages sound like an insinuation and an absolute statement. It&#39;s an attack on the author. They will definitely lead to justifications, rejections and a defensive stance. The author will not be thinking about how they can change, but rather how they can argue with you to show you that you are wrong. So the author will be less open for your feedback.

Using I-messages is the most important feedback rule in general and is clearly not limited to code reviews.

## **Talk About the Code, Not the Coder**

_Talking about the code increases the acceptance of your feedback, prevents pointless discussions and supports collective code ownership._

Wrong: &quot; **You****&#39; ****re requesting** the service multiple times, which is inefficient.&quot;

Right: &quot; **This code is requesting** the service multiple times, which is inefficient.&quot;

Take out the person in your feedback. Only talk about the code. Criticism on the code is much harder to take personally because you are simply talking about the code, an objective thing, and not the author. Again, this will improve the acceptance (as long as the author understands that they is not their code).

Moreover, this formulation prevents pointless discussions and finger-pointing like: &quot;No, it wasn&#39;t me introducing this request logic. It was Dave who originally introduced this feature!&quot;.

And finally, talking about the code supports the notion of [collective code ownership](https://www.martinfowler.com/bliki/CodeOwnership.html).

## **Ask Questions**

_Asking questions is a soft way to give feedback and to discover the author __&#39;__ s intention_

Wrong: &quot;This variable should have the name &#39;userId&#39;.&quot;

Right: &quot;What do you think about the name &#39;userId&#39; for this variable\*\*?\*\*&quot;

Asking questions feels much less like a criticism; it&#39;s just a question that the author can answer. But it can trigger a though process which can end with accepting the reviewer&#39;s feedback. Or the author can come up with a new, even better solution. In both cases, the acceptance is much higher.

Moreover, by asking questions you can reveal the intention behind a certain design decision. Maybe there is a good reason for this which you haven&#39;t known. If so, you have discovered the intention without any judgement (due to incomplete knowledge) that may upset the author.

## **Refer to the Author**

## **&#39;**

## **s Behavior, Not Their Attributes**

_Increase the acceptance of your feedback by only referring to the author __&#39;__ s behavior._

Wrong: &quot;You **are sloppy** when it comes to writing tests.&quot;

Right: &quot;I believe that you should **pay more attention** to writing tests.&quot;

Another general feedback tip is to criticize only the behavior of the author, not their attributes. Why? Attributes stick to a human and are really hard to change. That&#39;s why that feedback often feels like an attack on the human being itself and will probably lead to resistance. The author will start to argue with you instead of thinking about how to improve the situation. Behavior, however, can be changed more easily. Criticism on the behavior is less likely to be perceived as a personal attack. The author will be more open to your feedback.

However, usually, it&#39;s **not required to talk about the author at all** (neither their attributes nor behavior) in a code review. I strongly suggest to use I-messages, talk about the code or ask questions.

## **Mind the OIR-Rule of Giving Feedback**

Another good tool for giving feedback is to structure the feedback into three parts: Observation, Impact and Request.

| **Example** | **Notes** |
 |
| --- | --- | --- |
| Observation | &quot;This method has 100 lines.&quot; | Describe your observations in an objective and neutral way. Refer to the behavior if you have to talk about the author. Using an I-message is often useful here. |
| Impact | &quot;This makes it hard for me to grasp the essential logic of this method.&quot; | Explain the impact that the observation has on you. Use I-messages. |
| Request | &quot;I suggest extracting the low-level-details into subroutines and give them expressive names.&quot; | Use an I-message to express your wish or proposal. |

The OIR-Rule is a great help for phrasing constructive and [nonviolent](https://en.wikipedia.org/wiki/Nonviolent_Communication) feedback which doesn&#39;t trigger the author&#39;s defensive thread response.

## **Accept That There Are Different Solutions**

_Be aware of your personal taste, accept other solutions and make compromises_

Wrong: &quot;I always use fixed timestamps in tests and you should too.&quot;

Right: &quot;I would always use fixed timestamps in tests for better reproducibility but in this simple test, using the current timestamp is also ok.&quot;

You have to keep in mind that there are always different solutions to a problem. Most likely, you&#39;ll have a favorite solution, but the author&#39;s solution may also be valid. Don&#39;t force your solution on the author if their solution is also fine. **Distinguish between common best practices and your personal taste**. Mind that your skepticism may just reflect your personal taste and not an objectively wrong code. **Make compromises and be pragmatic**.

This mindset should prevent you from being uncompromising, pedantic and from annoying the author, which in turn reduces their openness to further feedback and may harm your relationship.

## **Don&#39;**

## **t Jump in Front of Every Train**

_Don&#39;__t jump in front of every train._

Don&#39;t be a pedant. Don&#39;t criticize every single line of code. Again, this would annoy the author and reduce their openness to further feedback and harm your relationship. And if your interpersonal relationship is destroyed, you have a much bigger problem than some not perfectly named variables. Instead, choose wisely the battles you are going to fight. Focus on the flaws and code smells that are most important to you.

I really like the metaphor used in [Debugging Teams](https://www.amazon.com/gp/product/1491932058/ref=as_li_tl?ie=UTF8&amp;camp=1789&amp;creative=9325&amp;creativeASIN=1491932058&amp;linkCode=as2&amp;tag=blogphilippha-20&amp;linkId=11df23d70998637d042bc6a46a4e6d1f) ![](RackMultipart20201228-4-1129e6b_html_1d7f9975b05d6279.png) to emphasis this hint:

&quot;_Every time a decision is made, it __&#39;__ s like a train coming through town — when you jump in front of the train to stop it you slow the train down and potentially annoy the engineer driving the train. A new train comes by every 15 minutes, and if you jump in front of every train, not only do you spend a lot of your time stopping trains, but eventually one of the engineers driving the train is going to get mad enough to run right over you. So, while it __&#39;__ s OK to jump in front of some trains, pick and choose the ones you want to stop to make sure you __&#39;__ re only stopping the trains that really matter.&quot;_ Fitzpatrick, Collins-Sussman: Debugging Teams, page 72

## **Praise**

_Don&#39;__t forget to praise._

Don&#39;t forget to express your appreciation if you have reviewed good code. Praising doesn&#39;t hurt you but will motivate the author and improve your relationship.

But your praise should be specific, concrete and separated from your criticism. Use different sentences and avoid sandwiching:

Wrong: &quot;Most of your code looks good, but the method calc() is too big.&quot;

Right: &quot;I really like the class ProductController, Tim. It has a clear single responsibility, is coherent, and contains nicely named methods. Good Job!
Despite this, I spotted the method calc() which is too big for me.&quot;

And last but not least: It&#39;s totally fine to say: &quot;Everything is good!&quot;. _No code changes_ is a valid outcome of a code review. Don&#39;t feel forced to find something in the code.

## **Three Filters For Feedback**

[April Wensel](https://twitter.com/aprilwensel) proposed a great approach in her talk [&#39;Compassionate (Yet Candid) Code Reviews&#39;](https://www.slideshare.net/AprilWensel/compassionate-yet-candid-code-reviews) to check your feedback. Before giving feedback, ask yourself:

_Always ask yourself, if your feedback is true, necessary and kind (Contribution: April Wensel)._

Those questions aim at many points that have already been covered in the previous sections. However, I like them because they provide a great mental crash barrier during code reviews.

### **Is it True?**

Wrong: &quot;You should use getter and setter. This code is wrong.&quot;

Is it true? This statement assumes an absolute truth, which rarely exists. Avoid the words &quot;right&quot;, &quot;wrong&quot; and &quot;should&quot;. Often, you only refer to your opinion. If so, say it:

Right: &quot;In this case, I would recommend using getter and setter, because…&quot;

Again, you can ask questions:

Right: &quot;Did you consider to use getter and setter?&quot;

If it&#39;s a fact, refer to a source (an official or the team&#39;s style guide):

Right: &quot;According to the Java style guide…&quot;

### **Is it Necessary?**

Wrong: &quot;There is a space missing here.&quot;

Is it necessary? I believe that there are more important things to talk about in a code review than missing spaces. Nagging tends to annoy the author. This corresponds with the advice to don&#39;t jump in front of every train.

Wrong: &quot; **This code sends a chill down my spine** , but I see your intention.&quot;

Is it necessary? The first part of the sentence has no sense. The reviewer only tries to show how cool they are. The only effect is that the author will feel bad and attacked. So always check your intention: Are you trying to help or boosting your ego?

Wrong: &quot;We should refactor this whole package.&quot;

Is it necessary to refactor the whole package in the scope of the current feature and code review? It&#39;s fine to detect those _big_ refactoring needs, but you should work on them separately. Consider to open a ticket or to have a dedicated meeting or chat with the whole team. Choose an appropriate channel.

Right: &quot;Let&#39;s discuss the refactoring in a dedicated meeting.&quot;

So the necessary-question has several aspects: To avoid nagging, unnecessary comments, and out-of-scope work.

### **Is it Kind?**

Wrong: &quot;A factory is **badly over-engineered** here. The **trivial** solution is to **just** use the constructor.&quot;

Is it necessary? No, and is it kind? Absolutely not! This statement is shaming. It gives the author the feeling of being stupid.

Being kind does _not_ mean that we grab us by the hands, sing &quot;Kumbaya My Lord&quot;, and stop saying something unpleasant. The point is, that being kind is a smart strategy to give feedback that will be accepted. It&#39;s efficient because you don&#39;t trigger someone&#39;s defensive reaction.

The following statement has the same message but without any shaming:

Right: &quot;This factory feels complicated to me. Have you considered to use a constructor instead?&quot;

## **The Code Review Cheat Sheet**

## **Rules For the Author**

For the author, it&#39;s important to have an **open and humble mindset** about the feedback they will receive.

- Be humble!
  - Mind that everybody&#39;s code can be improved.
  - You are not perfect.
  - Accept that you will make mistakes.
  - No matter how you good you are, you can still learn and improve.
  - Don&#39;t infer your professionalism and reliability as a software developer from infallibility and flawlessness.
- You are not your code
  - Programming is just a skill. It improves with training – and this never stops.
  - Don&#39;t connect your self-worth with the code you are writing.
- Mind that finally, the reviewer wants the same as you: Creating high-quality software. You are on the same side.
- Mind the IKEA effect. You might place a too high value on your own code.
- Consider feedback as a valuable new perspective on your code
  - It reveals your implicit knowledge that is not expressed in the code yet because it appears natural for you.
  - It avoids a tunnel vision.
- Code reviews are a valuable source of best practices and experiences
- Code reviews are a discussion, not a dictation. It&#39;s fine to disagree, but you have to elaborate your reservations politely and be willing to make compromises.

## **Rules For the Reviewer**

For the reviewer, it&#39;s important to pay attention to the way they **formulate the feedback**. This is extremely crucial for your feedback to be accepted.

- Use I-messages:
  - Right: &quot;It&#39;s hard for me to grasp what&#39;s going on in this code.&quot;
  - Wrong: &quot;You are writing cryptic code.&quot;
- Talk about the code, not the coder.
  - Right: &quot;This code is requesting the service multiple times, which is inefficient.&quot;
  - Wrong: &quot;You&#39;re requesting the service multiple times, which is inefficient.&quot;
- Ask questions instead of making statements.
  - Right: &quot;What do you think about the name &#39;userId&#39; for this variable\*\*?\*\*&quot;
  - Wrong: &quot;This variable should have the name &#39;userId&#39;.&quot;
- Always refer to the behavior, not the attributes of the author.
  - Right: &quot;I believe that you should pay more attention to writing tests.&quot;
  - Wrong: &quot;You are sloppy when it comes to writing tests.&quot;
- Accept that there are different solutions
  - Right: &quot;I would do it in another way, but your solution is also fine.&quot;
  - Wrong: &quot;I always do it this way and you should too.&quot;
  - Distinguish between common best practices and your personal taste.
  - Mind that your criticism may just reflect your personal taste and not an objectively wrong code.
  - Make compromises and be pragmatic.
- Don&#39;t jump in front of every train
  - Don&#39;t be a pedant. Don&#39;t criticize every single line in the code. This will annoy the author and reduce their openness to further feedback.
  - Focus on the flaws and code smells that are most important to you.
- Respect and trust the author
  - Nobody writes bad code on purpose.
  - The author wrote the code to the best of their knowledge and belief.
- Mind the OIR-Rule of giving feedback
  - Observation - &quot;This method has 100 lines.&quot;
  - Impact - &quot;This makes it hard for me to grasp the essential logic of this method.&quot;
  - Request - &quot;I suggest extracting the low-level-details into subroutines and give them expressive names.&quot;
- Before giving feedback, ask yourself:
  - Is it true? (opinion != truth)
  - Is it necessary? (avoid nagging, unnecessary comments and out-of-scope work)
  - Is it kind? (no shaming)
- Be humble! You are not perfect and you can also improve.
- It&#39;s fine to say: Everything is good!
- Don&#39;t forget to praise.

## **Further Reading**

- I highly recommend the book [Debugging Teams](https://www.amazon.com/gp/product/1491932058/ref=as_li_tl?ie=UTF8&amp;camp=1789&amp;creative=9325&amp;creativeASIN=1491932058&amp;linkCode=as2&amp;tag=blogphilippha-20&amp;linkId=11df23d70998637d042bc6a46a4e6d1f) ![](RackMultipart20201228-4-1129e6b_html_1d7f9975b05d6279.png) by Brian Fitzpatrick and Ben Collins-Sussman. Without exaggeration, this book inspired me.
- April Wensel: Talk [&#39;Compassionate (Yet Candid) Code Reviews&#39;](https://www.slideshare.net/AprilWensel/compassionate-yet-candid-code-reviews)
