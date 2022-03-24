Why I Prefer Makefiles Over package.json Scripts
================================================

On any moderately-sized Node.js project you've likely already outgrown the package.json "scripts" section. But because the growth was gradual, with no single acute pain point, you might not have noticed. There's a better way.

What Are NPM Scripts?
---------------------

In most Node.js projects you'll find a [scripts](https://docs.npmjs.com/cli/v7/using-npm/scripts) section in the package.json file, containing convenient shortcuts like "build" and "test":

JSON

```
"scripts":{
    "build":"tsc",
    "test":"jest -w 1"
}

```

These can be run with e.g. `npm run build` or `yarn test`.

In addition, there are special meanings behind scripts with certain names, like "install" or "prepublish" ([npm](https://docs.npmjs.com/cli/v7/using-npm/scripts#life-cycle-scripts),[yarn](https://classic.yarnpkg.com/en/docs/package-json#scripts-)).

On a new project it usually starts out innocent enough, with a small collection of simple, self-explanatory commands. But then...

Common Patterns
---------------

One pattern that I see come up often in NPM scripts is multiple variations on a single script:

JSON

```
    "go": "node go.js --do-some-stuff",
    "go:debug": "echo debugging..; DEBUG=1 yarn go",
    "go:there": "yarn go --to=\"over there\""

```

This is reasonably readable, but check out the same thing in [Make](https://en.wikipedia.org/wiki/Make_(software)):

MAKEFILE

```
GO_DO_STUFF=node go.js --do-some-stuff

go:
    ${GO_DO_STUFF}

go-debug:
    echo debugging..
    DEBUG=1 ${GO_DO_STUFF}

go-there:
    # watch out for the space in that argument:
    ${GO_DO_STUFF} --to="over there"

```

Variables. Multiple lines. No more escaped quotation marks. Comments.

Another pattern that comes up --- and this is a more sinister one --- is the chain of dependencies:

JSON

```
  "shared-prereq": "echo shared prereq!",
  "another-prereq": "echo another prereq!",
  "task-one": "yarn shared-prereq && echo doing task one..",
  "task-two": "yarn shared-prereq && yarn another-prereq ; echo doing task two.."

```

What if your build tool's syntax had a way to express dependencies?

MAKEFILE

```
shared-prereq:
    @echo shared prereq!

another-prereq:
    @echo another prereq!

task-one: shared-prereq
    @echo doing task one..

task-two: shared-prereq another-prereq
    @echo doing task two..

```

Amazing. But wait, it gets better...

Avoid Extra Work
----------------

In the above example we have a series of always-run steps, asking only of Make what we asked of our NPM scripts. But Make can do better.

If your commands are reading and writing a predictable set of files, then Make can track them and avoid redundant work.

This is a perfect fit for code generators (plug for [graphql-code-generator](https://github.com/dotansimha/graphql-code-generator), [openapi-typescript](https://github.com/drwpow/openapi-typescript), and [json-schema-to-typescript](https://github.com/bcherny/json-schema-to-typescript)).

Here's an example of using Make to describe the operations of a code generator:

MAKEFILE

```
JSON_SCHEMAS = $(shell find schemas -type f -name '*.schema.json')
JSON_SCHEMA_DST = $(JSON_SCHEMAS:%.schema.json=%.schema.gen.ts)

JSON2TS = yarn run json2ts

schemas/%.schema.gen.ts: schemas/%.schema.json
    $(JSON2TS) -i $< -o $@

CODEGEN_DST = ${JSON_SCHEMA_DST}

codegen: ${CODEGEN_DST}

build: ${CODEGEN_DST}
    @echo "I depend on those generated files!"

clean:
    find schemas -type f -name "*.gen.*" -delete

```

It's a little arcane, so here's what it does:

-   The first time you run `make build`, it will find all the `.schema.json` files, generate a `.gen.ts` for each one, and then continue building the app.
-   The second time you run `make build`, Make will see that the generated files are up-to-date, skip the generator, and build your app.
-   If you edit one of the schema files, Make will notice that just that filechanged, run the generator for it, then build your app.

Can your build tool do that?

Discoverability / Organization
------------------------------

On a large project, you can sprinkle multiple Makefiles in different directories, where they'll offer discoverable shortcuts related to that area of the application.

It's even more discoverable if your shell has smart tab completion: for example, on my current project, if you enter the `aws/` directory and type `make<TAB>`, you'll see a list that includes things like `docker-login`, `deploy-dev` and `destroy-sandbox`.

Bonus: It's Faster
------------------

This speaks for itself:

BASH

```
bash-3.2$ time yarn task-two
yarn run v1.22.5
$ yarn shared-prereq && yarn another-prereq ; echo doing task two..
$ echo shared prereq!
shared prereq!
$ echo another prereq!
another prereq!
doing task two..
✨  Done in 0.63s.

real    0m0.814s
user    0m0.508s
sys 0m0.138s

bash-3.2$ time make task-two
shared prereq!
another prereq!
doing task two..

real    0m0.021s
user    0m0.008s
sys 0m0.010s

```

Admittedly the tool overhead won't matter if your command takes any meaningful amount of time, but you'll feel the difference if you happen to have any scripts that execute instantly.

The Straw That Broke the Camel's Back
-------------------------------------

JSON was meant for serializing objects. It's a [lousy config format](https://spin.atomicobject.com/2019/05/20/document-package-json/), and it's even worse at expressing a complicated build.

As you pile more complexity into your NPM scripts, it never feels like you're the one placing the straw that breaks the camel's back. But please, take a step back, look at your poor camel, and consider using another tool.

I don't even care if it's Make. Use something else. Maybe your language ecosystem has a sweet build tool that can do all of the above. I'd love to be proven wrong, but as far as I know in Node.js (especially with Typescript), there isn't.

If you have more than a handful of extremely simple npm scripts, try Makefiles!

Further reading:

-   [Reduce Cognitive Overhead by Automating with GNU Make](https://spin.atomicobject.com/2016/03/28/automation-with-make/)
-   [A Super-Simple Makefile for Medium-Sized C/C++ Projects](https://spin.atomicobject.com/2016/08/26/makefile-c-projects/)