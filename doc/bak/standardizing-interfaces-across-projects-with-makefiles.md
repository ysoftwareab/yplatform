[Standardizing interfaces across projects with Makefiles](https://blog.capitaines.fr/2016/09/30/standardizing-interfaces-across-projects-with-makefiles/)
---------------------------------------------------------------------------------------------------------------------------------------------------------

If you are working on a non-trivial software solution, you probably have several projects. Maybe one for the frontend, and one for the backend? Maybe one for managing data, or secrets, or deployment? Or did you drink the micro-services kool-aid ([please don't](http://basho.com/posts/technical/microservices-please-dont/)), and have now dozen of projects, each one containing a small server?

In this case, the README file for these projects probably have a common structure ("How to setup", "How to run", "How to test") -- but all of them will contain different invocations. Sometime the project needs to be started with `npm run`, or `node server.js`, or `ember server` -- and some other project with `bundle exec rails server`, or maybe `./bin/server`.

What if we could instead express standard shortcuts for all these commands?

That's what Unix project maintainers have been doing for ages -- and also what we eventually did with Captain Train projects: we used Makefiles.

Overview
--------

We started to add a Makefile to each project, with a set of standardized commands:

-- `make install`, for installing or updating the dependencies,\
-- `make run`, for starting the server or the project,\
-- `make test`, for running tests,\
-- `make clean`, for removing all temporary and intermediate files.

Each command maps to the project-specific command.

For instance, the Makefile for our frontend webapp reads like something like this:

# frontend/Makefile

install: ## Install or update dependencies
    npm install
    bower install

run: ## Start the app server
    ember server

test: ## Run the tests
    ember test

clean: ## Clean temporary files and installed dependencies
    rm -rf ./tmp
    rm -rf ./node_modules
    rm -rf ./bower_components

.PHONY: install run test clean

Simple enough, eh?

Similarly, the Makefile of our Ruby backend looks like this:

# backend/Makefile

install: ## Install or update dependencies
    bundle install
    bundle exec rake db:migrate

run: ## Start the app server
    bundle exec rails server

test: ## Run the tests
    bundle exec rspec ./specs

clean: ## Clean temporary files and installed dependencies
    rm -rf ./tmp
    rm -rf ./vendor

.PHONY: install run test clean

(By the way, the `.PHONY` section ensures a file named `install` or `test` won't be considered as the target of a rule.)

We even make use of these [self-documenting Makefiles](https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html), to have a nice `make help` target that describes all available commands.

Why Makefiles
-------------

You can notice that in these examples we are not using much of the `make` features (namely building targets depending on the state of other files). So why using a Makefile -- rather than, say, ruby's `rake`, or even a bash script?

Well, the goal of this convention is to use the simplest tools, so that no dependency is required to run it. This rules out scripting languages like Ruby or Python: although they are often available on developers machines, we want a tool that can run and diagnose even a faulty or missing Ruby installation.

Makefiles should also be easy to write and to understand. Although it is quite possible to design a commands interpreted in a bash script, it is not simple. A declarative language like Makefiles is more suited to our goal: a list of commands, nothing more.

Caveats
-------

In our experience, there are a few guidelines that should be followed to ensure that these standardized Makefiles are really useful.

### Avoid coding in Makefiles

You really want to keep commands short and focused. Makefiles are a façade for standardized commands -- not a replacement for shell scripts.

If a target is starting to take more than a couple of lines, you should move it into a shell script. So `install: ./scripts/install.sh` is a very valid use of these Makefiles.

### Not everything has to go in

It's okay to keep some project-specific commands into shell scripts or custom commands, and to describe them in your README. Not every command has to go into the Makefile.

For instance, if one of your projects has to fetch a list of external data, you can keep your good old `bundle exec rake stations:fetch`.

(However, if several different projects start to use the same command, it can be a good idea to standardize a `make stations` command.)

### Keep those READMEs around

Makefiles are not a replacement for README files. Although Makefiles can express a standard interface, they don't give the same level of expressiveness that a good README can provide. You'll still want to document how your project performs some non-standard tasks, to document high-level technical choices, and so on.

### `make install` as a bootstrap

Diving into a new project should be easy for everyone: it encourages contributions, and other developers to care about other's code.

For this, running the project locally should be as easy as possible. This includes bootstrapping the project, and keeping up with the updates.

To help with this, we found that the `make install` command is best used when it can install or upgrade all required dependencies: the runtime, packages, modules, binaries... Running this command should Just Work™.

Conclusion
----------

If you only have one project, adopting this convention won't give you much. But when things start growing, it can make it easier for you to work on several projects at once.

Also, by reducing the cost for setup and the learning curve for each project, it encourages newcomer to jump into a foreign project, make a small fix, report bugs, clean a typo, and to just care about things.

This article was previously available at <https://blog.trainline.eu/13439-standardizing-interfaces-across-projects-with-makefiles>.
