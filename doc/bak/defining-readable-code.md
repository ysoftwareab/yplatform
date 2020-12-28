# **Defining readable code**

![](RackMultipart20201228-4-15q5nvr_html_540d348f3f37bf47.jpg)

11 March 2014 • 7 minute read • posted in [[Programming](https://wildlyinaccurate.com/category/Programming/), [Thoughts](https://wildlyinaccurate.com/category/Thoughts/) ]

Code readability is something that I often bring up during code reviews, but I often have trouble explaining _why_ I find a piece of code to be easy or difficult to read.

When you ask programmers how to make code easier to read, many of them will mention things like coding standards, descriptive naming, and decomposition. These things actually aid in making code easier to _comprehend_ rather than easier to _read_. For me, _readability_ is at a lower level, somewhere between legibility and comprehension.

![](RackMultipart20201228-4-15q5nvr_html_ea06413a397bd931.png)

_Legibility - Readability - Comprehension_

At the lowest level is legibility. This is how easily individual characters can be distinguished from each other, and can usually be boiled down to the choice of font, as well as the foreground &amp; background colours.

At the highest level is comprehension, which is the ease in which a block of code can be fully understood. Decomposition, naming conventions and comments are just a few of the many ways to improve comprehension.

Readability sits between these two. This level is a little harder to define, but I believe it comes down to two main factors: **structure** and **line density**.

## **Structure**

Our brains are very good at identifying structure and patterns; we find them pleasing. In the same sense, many people find a lack of structure to be quite displeasing. The effect of structure on readability can be easily demonstrated using an excerpt from this BBC article _[Indian probe begins journey to Mars](https://www.bbc.co.uk/news/science-environment-25163113)_.

India's mission to Mars has embarked on its 300-day journey to the Red Planet. Early on Sunday the spacecraft fired its main engine for more than 20 minutes, giving it the correct velocity to leave Earth's orbit. It will now cruise for 680m km (422m miles), setting up an encounter with its target on 24 September 2014.

India's mission to Mars has embarked on its 300-day journey to the Red Planet.

Early on Sunday the spacecraft fired its main engine for more than 20 minutes, giving it the correct velocity to leave Earth's orbit.

It will now cruise for 680m km (422m miles), setting up an encounter with its target on 24 September 2014.

Without even reading the content, the second version should appear more pleasant. The line breaks should give you a visual cue that each paragraph, while relevant, is not directly related to its neighbours. This is important because it lets you digest the text in smaller chunks which are much easier to comprehend by themselves than one big wall of text.

Breaking up large amounts of text into paragraphs is common practice in modern writing. Unfortunately, this practice doesn't seem to have been adopted by programmers. It's not uncommon to see code with no more than one sequential line break.

while(index--) {

digit = uid[index].charCodeAt(0);

if (digit == 57 /\*'9'\*/) {

uid[index] = 'A';

return uid.join('');

}

if (digit == 90 /\*'Z'\*/) {

uid[index] = '0';

} else {

uid[index] = String.fromCharCode(digit + 1);

return uid.join('');

}

}

The above is an excerpt from the [Mozilla Persona](https://github.com/mozilla/persona) source code. It's only 14 lines long, but you need to really engage your brain to read and understand it. Without some sort of paragraph structure, we have no way of knowing which lines are related, so we're forced to digest all 14 lines at once.

while(index--) {

digit = uid[index].charCodeAt(0);

if (digit == 57 /\*'9'\*/) {

uid[index] = 'A';

return uid.join('');

}

if (digit == 90 /\*'Z'\*/) {

uid[index] = '0';

} else {

uid[index] = String.fromCharCode(digit + 1);

return uid.join('');

}

}

With only 2 extra line breaks, the code has been changed from a single 14-line block to three distinct blocks, with the largest being only 6 lines. With this added structure, it's much easier to figure out what each block does: Block #1 sets the value of digit. Block #2 handles the case of digit being 57. Block #3 handles the case of digit being 90, and every other case as well. The difference may be trivial in this example, but applied to larger blocks of code this technique can save hours of time trying to read code.

There aren't any solid rules on when to separate blocks of code. Usually you should trust your gut and split code into blocks of related lines. As a guideline though, I tend to treat the following as separate blocks:

- Initialization &amp; assignment
- Control flow
- Data transformations

## **Line density**

Writers will often use [plain language](https://en.wikipedia.org/wiki/Plain_language) to reduce the _idea density_ of their text. This enables readers to quickly skim over text rather than making an effort to understand complex language. Programmers can use similar techniques to reduce what I call the _line density_ of code. Lines become dense when they contain too much logic. A good example is a complex if-statement.

if (x == 10 || x == 20 &amp;&amp; y == 2 || y == 5)

In this example, the reader must make a significant effort to determine that there are 3 possible &quot;truth&quot; conditions. The reason this requires so much effort is because we are required to read the line character-by-character until we find the ||, which we know separates each condition.

if (

x == 10 ||

x == 20 &amp;&amp; y == 2 ||

y == 5

)

By moving each condition onto its own line, the overall line density is reduced, thereby reducing the mental effort required to identify the conditions.

Line density also applies to function calls which take a large number of arguments.

doSomething(longVariableName, process(anotherVariable), ['array', 'of', 'things'], getSomethingFrom(SOME\_CONSTANT))

This can be made more readable by moving each argument onto a separate line.

doSomething(

longVariableName,

process(anotherVariable),

['array', 'of', 'things'],

getSomethingFrom(SOME\_CONSTANT)

)

## **Other factors**

There are plenty of other factors involved in code readability. But as with most things, readability is entirely subjective – it's important not to confuse it with personal preference.

Programming is an interesting mix of engineering and craft. As well as borrowing precision and discipline from engineering, we need to remember to also borrow style and ergonomics from visual design.
