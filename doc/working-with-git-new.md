# new git (and Github) repositories

## Creating a new repository locally

```shell
mkdir new-repo
cd new-repo
git init
```

Set up `support-firecloud` as a `git` submodule via

```shell
git submodule add -b master git://github.com/rokmoln/support-firecloud.git
git submodule update --init --recursive
```

In order to bootstrap/scaffold the repository, run

```shell
# for a generic repository
support-firecloud/bin/repo-generic-bootstrap

# for a Node.js repository
support-firecloud/bin/repo-node-bootstrap
```

and follow the instructions to supply the info.

In order to wrap up and complete the initial commit, run

```shell
# make sure you use the latest release, instead of the latest commit on master
make support-firecloud/update

git add .
git commit -m "initial commit"
```

## Creating a new repository on Github

[When creating a new repository](https://github.com/organizations/tobiipro/repositories/new),
it's recommended that you start with an **internal** if using Github Enterprise, or a **private** repository otherwise.

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
  * suffixed: [support-firecloud](https://github.com/rokmoln/support-firecloud)
  * mentioning software ecosystem: [eslint-config-firecloud](https://github.com/tobiipro/eslint-config-firecloud)

A description is optional by Github standards, but we require it.

No need to initialize a repository with a `README.md`, nor add a `.gitignore` or a `LICENSE`.
Just push these files from your local copy.

Once you've created the Github repository, remember to (see sections below):


### Add teams and collaborators

Go to `Settings` tab -> `Collaborators & Teams`.

* add entire teams, not individual team members
* if adding your team (who owns the repo), give it admin access
* remove yourself from collaborators (if you were added automatically by Github)


### Security Alerts

Allow Github to perform analysis of the dependency graph and provide security alerts by
going to `Settings` tab -> `Options` -> `Data services`.

* select `Allow GitHub to perform read-only analysis of this repository`
* select `Dependency graph`
* select `Security alerts`


### Merge button and protected master branch

Restrict merging strategies to always require a merge commit by
going to `Settings` tab -> `Options` -> `Merge button`.

* deselect `Allow squash merging`
* deselect `Allow rebase merging`

Under the same section, select `Automatically delete head branches` in order to keep the repository clean
from stale merged branches.

> **NOTE** If you're wondering why we restrict the merging strategies as they are currently implemented,
the issues with them include but are not limited to:

>  - fast-forward merge i.e. no merge commit referencing the PR number, the PR branch nor which commit the PR branched off from. In addition, the squashed/rebased commits have no comments, nor CI metadata attached
>  - committer will change for all squashed/rebased commits to `GitHub <noreply@github.com>` so no way of knowing who clicked the Merged button
>  - squashing a PR doesn't eliminate noise e.g. "lint", "moar fixes", and other silly commit messages, it simply blurs them and all the other useful commit messages into an opaque "Implement feature x" commit message. That type of noise can only be reduced/eliminated by an interactive rebase (e.g. `git rebase -i origin/master`) and the author cleaning up their PR branch
>  - simplicity in deciding which strategy to use. See [nodejs](https://github.com/nodejs/node/blob/913c365db66c7a0d40e72a463da4a2f3147f0c26/COLLABORATOR_GUIDE.md#landing-pull-requests) requirements for using the squash merge

Protect master branch against push-force, outdated PRs and optionally PRs without CI reviews by
going to `Settings` tab -> `Branches` -> `Add rule`.

* type `master`
* **optionally** select `Require pull request reviews before merging`
* select `Require status checks to pass before merging`
  * select `Travis CI - Pull Request`
    * if not available, [set up Travis CI integration first](./integrate-travis-ci.md)
* click `Create`

**NOTE** Do not enable `Require branches to be up to date before merging`,
because rather than rebasing your PR branch on top of the destination branch,
it will actually merge the destination (e.g. master) into your PR branch,
creating a spaghetti commit history, which might even have really negative consequences.
See [this comment](https://github.com/isaacs/github/issues/1113) for more.


### Add topics

Go to `Code` tab.

Topics will make it easier to filter our repositories, both public, internal and private ones.

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
