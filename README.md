# yplatform [![Github Actions CI Status][2]][1]

`yplatform` supports various cycles of software development, through a canonical set of commands.

`yplatform` aims to diminish **cognitive load** :massage:,
**time to first build** :stopwatch:
and **time to first deployment** :rocket: .
[Why?](#why)

This was conceived within [Tobii Pro's Cloud Services team](https://github.com/tobiipro/support-firecloud) :wave: .

![GitHub](https://img.shields.io/github/license/ysoftwareab/yplatform)
![GitHub contributors](https://img.shields.io/github/contributors-anon/ysoftwareab/yplatform)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/ysoftwareab/yplatform/master)
![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/m/ysoftwareab/yplatform/master)
![GitHub language count](https://img.shields.io/github/languages/count/ysoftwareab/yplatform)
![GitHub top language](https://img.shields.io/github/languages/top/ysoftwareab/yplatform)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/ysoftwareab/yplatform)
![GitHub repo size](https://img.shields.io/github/repo-size/ysoftwareab/yplatform)

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/ysoftwareab/yplatform)

---

## Table of Contents

* [Install standalone](#install-standalone)
* [Install in a project](#install-in-a-project)
* [Why?](#why)
* [Uniform interface](#uniform-interface)
* [Cross-platform](#cross-platform)
* [Cross-provider](#cross-provider)
* [Show me!](#show-me)
* [Repository structure](#repository-structure)
* [Documentation](#documentation)

---

## Install standalone

`git clone https://github.com/ysoftwareab/yplatform.git` and you will gain access to:
  * a bootstrap process for local-development based on GNU and Homebrew
    * [cross-platform](#cross-platform).
      * No more worries about this is how it works on a developer machine (e.g. MacOS/Windows) and this is how it works in the CI (e.g. Linux).
    * brings common GNU utilities (bash, make, grep, sed, find, etc), version locked.
      * No more worries about different flags, different behaviour or missing features!
    * brings [Homebrew](https://brew.sh).
      * No more worries about different versions available in distros' repositositories, or libraries/utilities not being available at all.
  * sane per-user configuration e.g. git
  * various utility scripts, 99% GNU Bourne Again Shell (Bash)
  * documentation and best common practices

---

## Install in a project

`bash -c "$(curl -qfsSL https://raw.githubusercontent.com/ysoftwareab/yplatform/master/bin/yp-install)"`
to install the latest `yplatform` (as a git submodule) to your project and you will gain access to:
  * a bootstrap process for CI machines based on GNU and Homebrew
    * [cross-provider](#cross-provider).
      No more worries about running pipelines with multiple CI providers, or switching to a new CI provider.
  * a build system based on GNU Make, both robust and flexible
  * sane per-repo configurations e.g. vscode
  * various utility scripts, 99% Bourne Again Shell (Bash)
  * a cloud infrastructure-as-code system based on GNU Make, both robust and flexible

---

## Why?

`yplatform` aims to diminish **cognitive load** :massage:,
**time to first build** :stopwatch:
and **time to first deployment** :rocket: .

This means **removing out-of-band information about system dependencies**.
How many times a repository's README mentions "something version x required"?
How many times it doesn't mention anything, and you end up looking for a CI/Docker configuration?

This means **removing differences in installing system dependencies**.
How many times did you look up "how to install X on Y?"
How many times did you discover that you get different system dependencies, depending on the version of your Linux distribution?

This means **removing differences in core utilities**.
How many times do you get something working on your MacOS development machine (BSD), only to see it fail on a CI machine, say running Ubuntu (GNU)?

This means **removing differences in installing local dependencies**.
How many times a repository's README mentions `npm install` or `yarn install` or `pip install` or `./configure --prefix=/usr; make`? Why should you care if this is a node/python/erlang/etc codebase, or what package manager it uses?

This means **removing differences in triggering a build, checks, tests, a deployment, etc** between codebases and their main programming language.
How many times did you check how to build a codebase, what language it is using, what package manager or test framework it is using, what services need to be up, etc?
How many times did you realize that checks are impossible to run locally, and that they run only in the CI, or worse - as a service reviewing/commenting your PR making it impossible to get early local feedback instead of feedback/noise in a Github pull request?
How many times did you return years after to an old codebase, of your own above all!, only to realize you have no clue what's needed to build it again?

This means **removing differences between what runs locally and what runs in the CI**.
How many times did you realize that you're instrumenting the CI ever-so-slightly-different than your local runs?
Because maybe you duplicated code in the `scripts` section of your `package.json` and your GitHub workflow YAML?

This means **removing differences between CI providers**.
How many times did you postpone trying out another CI provider?
How many times did you choose a provider based on previous experience, popularity, how easy it is to integrate,
rather than based on whether it is the most performant or the most appropriate for the job at hand?

This means **consolidating best current practices**.
How many times did you look up how to set up encryption in a `git` repository?
How many times did you reconfigure git with sane defaults or bump into CRLF/LF issues between system/developers?
How many times did you configure or postpone altogether configuring a gitops flow? Env branches, tags, changelog creation, etc?

This means **trying to make everything work the same everywhere**.
Emphasis on **trying**. In reality, 100% the same is not possible.
But it is possible to achieve say 80%.
And 80% is **much** better than 0% i.e. not trying at all.

---

## Uniform interface

Starting fresh with a new project or switching between projects doesn't mean you need to switch development context,
and instead you can focus on the business-logic context.

This mindset is useful for junior and senior developers alike. It makes onboarding new people as frictionless as possible.

Others have also been writing about this
as early as [2016](https://blog.capitaines.fr/2016/09/30/standardizing-interfaces-across-projects-with-makefiles/)
and as late as [2021](https://spin.atomicobject.com/2021/03/22/makefiles-vs-package-json-scripts/).

The entrypoint to all projects that use `yplatform` is

> Just type `make` !

`make` will fetch local dependencies, build the project and check that everything looks alright.
That's all you need to have a fully functional development environment.
Sometimes if your project has specific system dependencies, you may need to run `make bootstrap`.

"Then what?" you might ask.

> Just type `make help` !

And you get a nice list of self-documented targets.

Want to see all targets? Type `make help-all`.

Want to fetch dependencies alone? Type `make deps`.

Want to build and skip dependencies and checks? Type `make build`.

What to run checks alone (i.e. linters)? Type `make check`.

Want to run tests? Type `make test`.

Want to release a new version as a git tag with automatic release notes based on git commits? Type `make release`.

Want to see commits since last release? Type `make unreleased`.

Want to promote a version to an environment branch?
A branch that is coupled to a CI that deploys your software to a staging environment for example?
Type `make promote-env/staging/v1.2.3` for example.

Do you have secrets checked in and want to decrypt them transparently via git clean/smudge filters? Type `make decrypt`.

Do you want to reset your local git repository as if it was freshly cloned? Type `make nuke`.

And the list goes on and on and on. Fully extensible. Preloaded with minimal best current practices.

---

## Cross-platform

Similarly `yplatform` itself runs across these platforms with very little effort and no duplication. Bootstrapped Docker images are also available.

| Platform                | minimal            | common             | minimal (Docker)                                                                          | common (Docker)                                                                         |
| ----------------------- | ------------------ | ------------------ | ----------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Apple MacOS             | :heavy_check_mark: | :heavy_check_mark: |                                                                                           |                                                                                         |
| Linux (Alpine 3.15)     | :heavy_check_mark: | :heavy_check_mark: | [yp-alpine-3.15-minimal](https://hub.docker.com/r/ysoftwareab/yp-alpine-3.15-minimal)     | [yp-alpine-3.15-common](https://hub.docker.com/r/ysoftwareab/yp-alpine-3.15-common)     |
| Linux (Amazonlinux 2)   | :heavy_check_mark: | :heavy_check_mark: | [yp-amzn-2-minimal](https://hub.docker.com/r/ysoftwareab/yp-amzn-2-minimal)               | [yp-amzn-2-common](https://hub.docker.com/r/ysoftwareab/yp-amzn-2-common)               |
| Linux (Archlinux)       | :heavy_check_mark: | :heavy_check_mark: | [yp-arch-0-minimal](https://hub.docker.com/r/ysoftwareab/yp-arch-0-minimal)               | [yp-arch-0-common](https://hub.docker.com/r/ysoftwareab/yp-arch-0-common)               |
| Linux (Centos Stream 8) | :heavy_check_mark: | :heavy_check_mark: | [yp-centos-8-minimal](https://hub.docker.com/r/ysoftwareab/yp-centos-8-minimal)           | [yp-centos-8-common](https://hub.docker.com/r/ysoftwareab/yp-centos-8-common)           |
| Linux (Debian 9)        | :heavy_check_mark: | :heavy_check_mark: | [yp-debian-9-minimal](https://hub.docker.com/r/ysoftwareab/yp-debian-9-minimal)           | [yp-debian-9-common](https://hub.docker.com/r/ysoftwareab/yp-debian-9-common)           |
| Linux (Debian 10)       | :heavy_check_mark: | :heavy_check_mark: | [yp-debian-10-minimal](https://hub.docker.com/r/ysoftwareab/yp-debian-10-minimal)         | [yp-debian-10-common](https://hub.docker.com/r/ysoftwareab/yp-debian-10-common)         |
| Linux (RHEL 8.5)        |                    |                    | yp-rhel-8.5-minimal                                                                       | yp-rhel-8.5-common                                                                      |
| Linux (Ubuntu 18.04)    | :heavy_check_mark: | :heavy_check_mark: | [yp-ubuntu-18.04-minimal](https://hub.docker.com/r/ysoftwareab/yp-ubuntu-18.04-minimal)   | [yp-ubuntu-18.04-common](https://hub.docker.com/r/ysoftwareab/yp-ubuntu-18.04-common) |
| Linux (Ubuntu 20.04)    | :heavy_check_mark: | :heavy_check_mark: | [yp-ubuntu-20.04-minimal](https://hub.docker.com/r/ysoftwareab/yp-ubuntu-20.04-minimal)   | [yp-ubuntu-20.04-common](https://hub.docker.com/r/ysoftwareab/yp-ubuntu-20.04-common) |
| Linux (Ubuntu 22.04)    | :heavy_check_mark: | :heavy_check_mark: | [yp-ubuntu-22.04-minimal](https://hub.docker.com/r/ysoftwareab/yp-ubuntu-22.04-minimal)   | [yp-ubuntu-22.04-common](https://hub.docker.com/r/ysoftwareab/yp-ubuntu-22.04-common) |
| Microsoft Windows (WSL) | :heavy_check_mark: | :zzz:              |                                                                                           |                                                                                         |

**NOTE** RHEL needs entitlement certificates in the CI.

**NOTE** `common` install is paused for `Microsoft Windows (WSL)` because the process takes more than 1 hour on Github Actions CI
(a combination of machine specs and being restricted to WSL v1), but we expect no problems.

**NOTE** it should even possible to create WSL images, and even OCI/podman images. Tracked in [#213](https://github.com/ysoftwareab/yplatform/issues/213).

---

## Cross-provider

`yplatform` itself currently runs across these providers with very little effort and no duplication.

| Provider          | yplatform status                    | master             | provider-branches  | version tags       | PR                 | config                               | env                              |
| ----------------- | ----------------------------------- | ------------------ | ------------------ | ------------------ | ------------------ | ------------------------------------ | -------------------------------- |
| AppVeyor          | [![AppVeyor Status][14]][13]        | :heavy_check_mark: | `appveyor*`        |                    |                    | [config](./appveyor.yml)             | [env](./ci/env/appveyor.inc.sh)  |
| Bitrise           | [![Bitrise Status][22]][21]         | :zzz:              | `bitrise*`         |                    |                    | [config](./bitrise.yml)              | [env](./ci/env/bitrise.inc.sh)   |
| Buddy             | [![Buddy Status][20]][19]           | :heavy_check_mark: | `buddy*`           |                    |                    | [config](./buddy.yml)                | [env](./ci/env/buddy.inc.sh)     |
| CircleCI          | [![CircleCI Status][4]][3]          | :heavy_check_mark: | `circle*`          | :heavy_check_mark: | :heavy_check_mark: | [config](./.circleci)                | [env](./ci/env/circle.inc.sh)    |
| Cirrus CI         | [![Cirrus CI Status][16]][15]       | :heavy_check_mark: | `cirrus*`          |                    | :heavy_check_mark: | [config](./.cirrus.yml)              | [env](./ci/env/cirrus.inc.sh)    |
| Codeship          | [![Codeship Status][8]][7]          | :heavy_check_mark: | `codeship*`        |                    |                    | [config](./codeship-steps.yml)       | [env](./ci/env/codeship.inc.sh)  |
| Drone CI          | [![Drone CI Status][24]][23]        | :heavy_check_mark: | `drone*`           |                    |                    | [config](./.drone.yml)               | [env](./ci/env/drone.inc.sh)  |
| Github Actions CI | [![Github Actions CI Status][2]][1] | :heavy_check_mark: | `github*`          | :heavy_check_mark: | :heavy_check_mark: | [config](./.github/workflows)        | [env](./ci/env/github.inc.sh)    |
| Gitlab CI         | [![Gitlab CI Status][12]][11]       | :heavy_check_mark: | `gitlab*`          |                    |                    | [config](./.gitlab-ci.yml)           | [env](./ci/env/gitlab.inc.sh)    |
| Semaphore         | [![Semaphore Status][10]][9]        | :heavy_check_mark: | `semaphore*`       |                    | :heavy_check_mark: | [config](./.semaphore/semaphore.yml) | [env](./ci/env/semaphore.inc.sh) |
| Sourcehut         | [![Sourcehut Status][18]][17]       | :heavy_check_mark: | `sourcehut*`       |                    | :heavy_check_mark: | [config](./.builds/sourcehut.yml)    | [env](./ci/env/sourcehut.inc.sh) |

**NOTE** Bitrise builds for the `master` branch run only once a day due to freemium limits.

We have also integrated in the past with more CI providers

| Provider          | yplatform status                    | master             | provider-branches  | version tags       | PR                 | config                               | env                              |
| ----------------- | ----------------------------------- | ------------------ | ------------------ | ------------------ | ------------------ | ------------------------------------ | -------------------------------- |
| Travis CI         | [![Travis CI Status][6]][5]         | :zzz:              | `travis*`          |                    |                    | [config](./.travis.yml)              | [env](./ci/env/travis.inc.sh)    |

**NOTE** Travis CI builds for the `master` branch are paused because one has to constantly ask for more open-source credits.

* Integration with Travis CI is unstable since it now requires a subscription.
* [The new pricing model for travis-ci.com](https://blog.travis-ci.com/2020-11-02-travis-ci-new-billing)
* [Travis CI's new pricing plan threw a wrench in my open source works](https://www.jeffgeerling.com/blog/2020/travis-cis-new-pricing-plan-threw-wrench-my-open-source-works)
* [Travis CI is no longer providing CI minutes for open source projects](https://news.ycombinator.com/item?id=25338983)

---

## Show me!

### Show me macOS and Ubuntu 20.04 bootstrapping

[This is a bootstrapping of a fresh macOS developer machine.](https://asciinema.org/a/465585)

Had to input my password (e.g. to install [Homebrew](https://brew.sh)) and
decide post-installation if I optionally want to switch my shell from zsh to bash,
something that is useful for those that are not techies.
All done in 10 minutes. Set for life.
[Watch it at 10x, then it's only 1 minute.](https://asciinema.org/a/465587) :sunglasses:

[Second video is a bootstrapping of a fresh Ubuntu 20.04 developer machine.](https://asciinema.org/a/465523)
Had to input my password (e.g. to install some aptitude packages and [Homebrew](https://brew.sh)) and
input my timezone.
All done in 10 minutes. Set for life.
[Watch it at 10x, then it's only 1 minute.](https://asciinema.org/a/465524) :sunglasses:

<a href="https://asciinema.org/a/465585" target="_blank"><img src="https://asciinema.org/a/465585.svg" width="45%" /></a>
<a href="https://asciinema.org/a/465523" target="_blank"><img src="https://asciinema.org/a/465523.svg" width="45%" /></a>

### Show me ways-of-working with a project with `yplatform`

This is a cloning of a project on a macOS developer machine,
and installing project-specific system dependencies.

Second video shows opening the same project,
and playing around without actually having to know anything about it.

<a href="https://asciinema.org/a/465932" target="_blank"><img src="https://asciinema.org/a/465932.svg" width="45%" /></a>
<a href="https://asciinema.org/a/465933" target="_blank"><img src="https://asciinema.org/a/465933.svg" width="45%" /></a>

---

## Repository structure

* [`/bin`](./bin) has executable scripts, 99% GNU Bourne Again Shell (Bash)
* [`/build.mk`](./build.mk) has build-system makefiles
* [`/bootstrap`](./bootstrap) has scripts that help bootstrap a machine
* [`/ci`](./ci) has scripts that help steer the CI pipelines
* [`/dev`](./dev) has scripts that help bootstrap a developer machine
* [`/dockerfiles`](./dockerfiles) has scripts for the bootstrapped Docker images
*
* [`/gitconfig`](./gitconfig) has git configuration
* [`/sshconfig`](./sshconfig) has ssh configuration
*
* [`/repo`](./repo) has configuration that is repo-specific, for those repositories bootstrapped with `yplatform`
*
* [`/mk`](./mk) has common include makefiles e.g. sourced from `/build.mk` makefiles
* [`/sh`](./sh) has common include shell scripts e.g. sourced from `/bin` shell scripts

---

## Documentation

* newcomer
  * [bootstrap](bootstrap/README.md)
* daily work
  * [code of conduct](https://github.com/ysoftwareab/.github/.github/CODE_OF_CONDUCT.md)
  * [contributing via `git` (and Github Pull Requests)](https://github.com/ysoftwareab/.github/.github/CONTRIBUTING.md)
  * [working with `make`](build.mk/README.md)
  * [working with a local `npm` dependency](doc/working-with-a-local-npm-dep.md)
  * [how to release](doc/how-to-release.md)
  * style
    * `Use common sense and BE CONSISTENT. (Google)`
    * [Less than 120 cpl, preferably less than 80](doc/style-maxlen.md)
    * [shell](doc/style-sh.md)
    * [Makefile](doc/style-mk.md)
    * [JavaScript/TypeScript](https://github.com/ysoftwareab/eslint-config-firecloud)
    * [SASS](https://github.com/ysoftwareab/sass-lint-config-firecloud)
* set up a new `git` repository
  * [new `git` (Github) repositories](doc/creating-new-github-repo.md)
  * [how to license](doc/how-to-license.md)
  * [integrate Travis CI](doc/integrate-travis-ci.md)
  * [.ci.sh](ci/README.md)
  * [how to manage secrets](doc/how-to-manage-secrets.md)
* Amazon Web Services
  * [CloudFormation](aws-cfn.mk/README.md)
  * [Identity Access Management](doc/aws-iam.md)

---

## Writing

* https://developers.google.com/tech-writing/overview
* https://github.com/google/styleguide/blob/gh-pages/docguide/philosophy.md
* https://www.julian.com/guide/write/intro

---

## License

[Apache-2.0](LICENSE)


  [1]: https://github.com/ysoftwareab/yplatform/actions/workflows/main.yml?query=branch%3Amaster
  [2]: https://github.com/ysoftwareab/yplatform/actions/workflows/main.yml/badge.svg?branch=master
  [3]: https://circleci.com/gh/ysoftwareab/yplatform/tree/master
  [4]: https://circleci.com/gh/ysoftwareab/yplatform/tree/master.svg?style=shield
  [5]: https://app.travis-ci.com/ysoftwareab/yplatform
  [6]: https://app.travis-ci.com/ysoftwareab/yplatform.svg?branch=master
  [7]: https://app.codeship.com/projects/388210
  [8]: https://app.codeship.com/projects/8fe9ad00-438f-0138-d313-2e664bcb50ed/status?branch=master
  [9]: https://ysoftwareab.semaphoreci.com/projects/yplatform
  [10]: https://ysoftwareab.semaphoreci.com/badges/yplatform/branches/master.svg?style=shields
  [11]: https://gitlab.com/ysoftwareab/yplatform/commits/master
  [12]: https://gitlab.com/ysoftwareab/yplatform/badges/master/pipeline.svg
  [13]: https://ci.appveyor.com/project/andreineculau/yplatform/branch/master
  [14]: https://ci.appveyor.com/api/projects/status/da744jauw31fi66h/branch/master?svg=true
  [15]: https://cirrus-ci.com/github/ysoftwareab/yplatform/master
  [16]: https://api.cirrus-ci.com/github/ysoftwareab/yplatform.svg?branch=master
  [17]: https://builds.sr.ht/~andreineculau/yplatform/commits/sourcehut.yml
  [18]: https://builds.sr.ht/~andreineculau/yplatform/commits/sourcehut.yml.svg
  [19]: https://app.buddy.works/ysoftwareab-1/yplatform/pipelines/pipeline/399186
  [20]: https://app.buddy.works/ysoftwareab-1/yplatform/pipelines/pipeline/399186/badge.svg?token=8f7b2ec2101eb8f5dec2ce6108a50eb34ff3629b5434826f24bd4152251f2bd5
  [21]: https://app.bitrise.io/app/d4c696b6b4e2be16
  [22]: https://app.bitrise.io/app/d4c696b6b4e2be16/status.svg?token=HzPGqHokXBO_ta7E3WvWeQ&branch=master
  [23]: https://cloud.drone.io/ysoftwareab/yplatform
  [24]: https://cloud.drone.io/api/badges/ysoftwareab/yplatform/status.svg
