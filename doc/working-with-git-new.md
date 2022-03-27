# new git (and Github) repositories

## Creating a new repository locally

```shell
mkdir new-repo
cd new-repo
git init
git commit --allow-empty -m "[empty] initial commit"
```

Set up `yplatform` as a `git` submodule via

```shell
bash -c "$(curl -qfsSL https://raw.githubusercontent.com/ysoftwareab/yplatform/master/bin/yp-install)"
```

In order to bootstrap/scaffold the repository, run

```shell
# for a generic repository
yplatform/bin/repo-generic-bootstrap

# for a Node.js repository
yplatform/bin/repo-node-bootstrap
```

and follow the instructions to supply the info.

In order to wrap up and complete the initial commit, run

```shell
git add .
git commit -m "bootstrapped with yplatform"
```

## Creating a new repository on Github

[When creating a new repository](https://github.com/organizations/ysoftwareab/repositories/new),
it's recommended that you start with an **internal** if using Github Enterprise, or a **private** repository otherwise.

Once you push your commits, you and your team members can then inspect and verify
that everything looks ok, and only then make it public.

> There are only two hard things in Computer Science: cache invalidation and naming things. -- Phil Karlton
> https://martinfowler.com/bliki/TwoHardThings.html

Please name the repository appropriately, where appropriately stands for, but not only:
* descriptive and unique e.g. a real name, an accronym
  * a real name: [minlog](https://github.com/ysoftwareab/minlog)
  * an accronym: [KATT](https://github.com/for-GET/katt)
* if not unique then prefixed or suffixed with team name and mentioning software ecosystem
  * prefixed: [yplatform](https://github.com/ysoftwareab/yplatform)
  * suffixed after software ecosystem: [eslint-plugin-y](https://github.com/ysoftwareab/eslint-plugin-y)

A description is optional by Github standards, but we require it.

No need to initialize a repository with a `README.md`, nor add a `.gitignore` or a `LICENSE`.
Just push these files from your local copy as per Github's `...or push an existing repository from the command line` instructions.

```shell
git remote add origin git@github.com:<org>/<repo>.git
git push -u origin master
```

Once you've created the Github repository, remember to apply the settings below.

**NOTE** You can apply most of them by editing installing
the Probot Settings app](https://probot.github.io/apps/settings/),
and editing`.github/settings.yml` with the `name` and `description`.


### Settings -> General -> Features

Disable not-applicable features by
going to `Settings` tab -> `General` -> `Features`.

* **optionally** disable `Wikis`
* **optionally** disable `Issues`
* **optionally** disable `Projects`


### Settings -> General -> Pull Request

Restrict merging strategies to always require a merge commit by
going to `Settings` tab -> `General` -> `Pull request`.

* disable `Allow squash merging`
* disable `Allow rebase merging`

Under the same section, enable `Automatically delete head branches` in order to keep the repository clean
from stale merged branches.

> **NOTE** If you're wondering why we restrict the merging strategies as they are currently implemented,
the issues with them include but are not limited to:

>  - fast-forward merge i.e. no merge commit referencing the PR number, the PR branch nor which commit the PR branched off from. In addition, the squashed/rebased commits have no comments, nor CI metadata attached
>  - committer will change for all squashed/rebased commits to `GitHub <noreply@github.com>` so no way of knowing who clicked the Merged button
>  - squashing a PR doesn't eliminate noise e.g. "lint", "moar fixes", and other silly commit messages, it simply blurs them and all the other useful commit messages into an opaque "Implement feature x" commit message. That type of noise can only be reduced/eliminated by an interactive rebase (e.g. `git rebase -i origin/master`) and the author cleaning up their PR branch
>  - simplicity in deciding which strategy to use. See [nodejs](https://github.com/nodejs/node/blob/913c365db66c7a0d40e72a463da4a2f3147f0c26/COLLABORATOR_GUIDE.md#landing-pull-requests) requirements for using the squash merge


### Settings -> Code and automation -> Branches

Protect master branch against push-force, outdated PRs and optionally PRs without CI reviews by
going to `Settings` tab -> `Code and automation` -> `Branches` -> `Add rule`.

* type `master`
* **optionally** enable `Require pull request reviews before merging`
  * enable `Require approvals`
  * enable `Dismiss stale pull request approvals when new commits are pushed`
* enable `Require status checks to pass before merging`
  * do NOT enable `Require branches to be up to date before merging`
    * rather than rebasing your PR branch on top of the destination branch,
      it will actually merge the destination (e.g. master) into your PR branch,
      creating a spaghetti commit history, which might even have really negative consequences.
      See [this comment](https://github.com/isaacs/github/issues/1113) for more
  * select the relevant CI checks
    * if not available, configure the CI first, create a PR and come back here
* **optionally** enable `Require signed commits`
  * This will make it impossible to commit from Github UI.
* click `Create`


### Settings -> Access -> Collaborators and teams

Go to `Settings` tab -> `Access` -> `Collaborators and teams`.

* add entire teams, not individual team members
* if adding your team (who owns the repo), give it admin access
* remove yourself from collaborators (if you were added automatically by Github)


### Settings -> Security -> Code security and analysis

Allow Github to perform analysis of the dependency graph and provide security alerts by
going to `Settings` tab -> `Security` -> `Code security and analysis`.

* enable `Dependency graph`
* enable `Dependabot alerts`
* enable `Dependabot security updates`


### Code -> Edit repository metadata -> Topics

Go to `Code` tab -> `Edit repository metadata` (gear icon) -> `Topics`.

Topics will make it easier to filter our repositories, both public, internal and private ones.

**Topics are also public, making them a good marketing trick. So unless the topic is generic, do prefix it with ysoftwareab !!!**

* team/project name e.g. `company-frontend`, `company-merlin`
* purpose e.g, `eslint-config` or `eslint-plugin`
* related software e.g. `eslint`
* etc
