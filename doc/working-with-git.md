# git (and Github)

## Github onboarding

* Have an account? If not [register one](https://github.com/join).
  * Register with your personal email, if possible. You will surely have a Github account beyond your stay at Tobii.
* Go to https://github.com/settings/profile and fill in some info and **upload a picture**.
* Go to https://github.com/settings/emails and **register your @tobii.com email address**.
  * Keep the personal one as the primary one.
* Go to https://github.com/settings/security and **enable Two-factor**.
* Follow the instructions below and **setup [Github notifications](#github-notifications)**.

## Github notifications

Notifications are nice, and even necessary to have,
but they need to come in the right amount and on proper channels.

The right amount can be fixed by going to https://github.com/settings/notifications
and **turning off `Automatically watch repositories`**.

The proper channels can be fixed by going to https://github.com/settings/emails
and registering your @tobii.com email address, if you haven't done so already.
Once that is done, go to https://github.com/settings/notifications#organization_routing
and select the @tobii.com email address for the Tobii organizations.

## Feature branches

We use a convention of prefixing feature branches with `f/`.
The term `feature` is overloaded, as it means any topic e.g. `bug`, `emergency-fix`, `user`, etc.

This allows different systems, like the CI/CD, to make certain decisions based on the name of the branch.

One sensible thing to do further is to have your branches start with a unique indicative,
like your username e.g.

* GOOD `f/anu-add-logo` (`anu` is my username)
* GOOD `f/add-logo`
* DONT `add-logo`

---

## Creating a new repository locally

Set up `support-firecloud` as a `git` submodule via

```shell
git submodule add -b master git://github.com/tobiipro/support-firecloud.git

# for a generic repository
support-firecloud/bin/repo-generic-bootstrap

# for a Node.js repository
support-firecloud/bin/repo-node-bootstrap
```

Follow the instructions to supply the info.


## Creating a new repository on Github

[When creating a new repository](https://github.com/organizations/tobiipro/repositories/new),
it's recommended that you start with a **private** repository.

Once you push your commits, you and your team members can then inspect and verify
that everything looks ok, and only then make it public.

> There are only two hard things in Computer Science: cache invalidation and naming things. -- Phil Karlton
> https://martinfowler.com/bliki/TwoHardThings.html

Please name the repository appropriately, where appropriately stands for, but not only:
* descriptive and unique e.g. a real name, an accronym
  * a real name: [minlog](https://github.com/tobiipro/minlog)
  * an accronym: [KATT](https://github.com/for-GET/katt)
* if not unique then prefixed or suffixed with team name and mentioning software ecosystem
  * prefixed: firecloud-dashboard
  * suffixed: [support-firecloud](https://github.com/tobiipro/support-firecloud)
  * mentioning software ecosystem: [eslint-config-firecloud](https://github.com/tobiipro/eslint-config-firecloud)

A description is optional by Github standards, but we require it.

No need to initialize a repository with a `README.md`, nor add a `.gitignore` or a `LICENSE`.
Just push these files from your local copy.

Once you created the Github repository, remember to (see sections below):


### Add teams and collaborators

Go to `Settings` tab -> `Collaborators & Teams`.

* add entire teams, not individual team members
* if adding your team (who owns the repo), give it admin access
* remove yourself from collaborators (if you were added automatically by Github)


### Add topics

Go to `Code` tab.

Topics will make it easier to filter our repositories, both public and private ones.

**Topics are also public, making them a good marketing trick. So unless the topic is generic, do prefix it with tobii- or tobii-pro- !!!**

* team/project name e.g. `tobii-firecloud`, `tobii-pro-sdk`
* purpose e.g, `eslint-config` or `eslint-plugin`
* related software e.g. `eslint`
* etc


### Push your local repository

```shell
cd path/to/repo
git remote add origin git@github.com:tobiipro/example.git
git push -u
```
