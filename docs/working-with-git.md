# git

## Creating a new repository locally

Set up `support-firecloud` as a `git` submodule via

```shell
git submodule add support-firecloud git://github.com/tobiipro/support-firecloud.git

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

* add entire teams, not individual team members
* when adding your team, give it admin access


### Add topics

Topics will make it easier to filter our repositories, both public and private ones.

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
