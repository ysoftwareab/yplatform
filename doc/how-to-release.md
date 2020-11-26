# How to release

Below you will find flows that talk about `npm` packages and webapps and libraries.
Those are purely for the purpose of giving simple examples.
The same flows apply to any repository that has been bootstrapped with `support-firecloud`, no matter the programming languaguage.


## Semantic Versioning

See https://semver.org/spec/v2.0.0.html .

**TL;DR** :

* pre-public versions
  * `0.0.1` initial version
  * `0.0.2` minor version with **bugfixes, new features**
  * `0.1.0` major version with bugfixes, new features, **breaking changes**
* public versions
  * `1.0.0` initial public version
  * `1.0.1` patch version with **bugfixes**
  * `1.1.0` minor version with bugfixes, **new features**
  * `2.0.0` major version with bugfixes, new features, **breaking changes**


**You don't need to remember all of these if you use the `make release/*` targets below.**

* `make release/bugfix` is equivalent to
  * `make release/patch` for pre-public versions
  * `make release/patch` for public versions
* `make release/feature` is equivalent to
  * `make release/patch` for pre-public versions
  * `make release/minor` for public versions
* `make release/breaking` is equivalent to
  * `make release/minor` for pre-public versions
  * `make release/major` for public versions
* `make release/public` is equivalent to
  * `make release/v1.0.0`


## `npm` packages as `git` tags

**NOTE** This section applies to packages which you intend to use
as dependencies for other packages i.e. this section is for library repositories, not webapp repositories.

In order to simplify the release process and not depend on `npm` registries,
we publish to the `git` repository itself thanks to [npm-publish-git](https://github.com/andreineculau/npm-publish-git).

If that sounds weird to you, it is not. `npm` had support for
git urls as dependencies](https://docs.npmjs.com/files/package.json#git-urls-as-dependencies)
for a long time.

The biggest counter-argument to `git` urls as dependencies is that
you end up checking out the source, the submodules, devDependecies, building, etc. every time you install the dependency,
although you are only interested in the artifact.

And this is what `npm-publish-git` addresses.
What you end up having in a `git` tag is an exact match of what would be available on a `npm` registry,
so there are no `git` submodules to checkout, no devDependecies to install, no build process.
Read more in the [`npm-publish-git` README](https://github.com/andreineculau/npm-publish-git/blob/master/README.md).

An example flow for publishing [`minlog`](https://github.com/rokmoln/minlog)
which in its [Makefile](https://github.com/rokmoln/minlog/blob/master/Makefile) is using

* [repo/mk/node.common.mk](../repo/mk/node.common.mk)
* [repo/mk/core.misc.release.npg.mk](../repo/mk/core.misc.release.npg.mk)

```
cd path/to/minlog

# make changes

# save changes
git add
git commit -m "some changes"

# create a clean (nuked) build
# and bump the patch version
# and create a `git` tag via `npm version patch` e.g. v0.0.1
# and publish by overwriting it (old v0.0.1 tag is renamed to v0.0.1-src)
make release
```

From this point on, using `git://github.com/rokmoln/minlog.git#v0.0.1`
or `git://github.com/rokmoln/minlog.git#semver:~0.0.1` is **exactly** the same
as if `minlog` would be published on the `npm` registry
and you would have used only `0.0.1`, respectively `~0.0.1`, as a version specifier.


## `npm` packages as `github` artifacts

**NOTE** This section applies to repositories which you do **NOT** intend to use
as dependencies for other packages i.e. this section is for webapp repositories, not library repositories.

`github` releases support [attaching artifacts (or binaries)](https://help.github.com/articles/creating-releases/).

One could manually create a release, or create one automatically via the CI.

We have this working for a few private repositories, integrated with Travis CI.

An example of a repository which in its Makefile is using

* [repo/mk/js.common.node.mk](../repo/mk/js.common.node.mk)
* [repo/mk/js.publish.tag.mk](../repo/mk/js.publish.tag.mk)

```
cd path/to/repo

# make changes

# save changes
git add
git commit -m "some changes"

# create a clean (nuked) build
# and bump the patch version
# and create a `git` tag via `npm version patch` e.g. v0.0.1
# and publish by pushing the v0.0.1 tag to the remote as is
make release

# this is then picked up by Travis CI, which will then publish the artifacts as a github release
```

Travis CI is then configured with

1. a personal access token giving `:repo` access, via a `GH_TOKEN` environment variable
2. a deploy flow, via `.travis.yml` with:

```yml
# 6. Deploy
before_deploy: ./.ci.sh before_deploy
deploy:
  - provider: script
    script: ./.ci.sh deploy
    skip_cleanup: true
    on:
      tags: true
after_deploy: ./.ci.sh after_deploy
```

`.ci.sh` is then configured with

```bash
ci_run_deploy() {
    local GIT_TAG=$(git tag -l --points-at HEAD | head -1)

    ${SUPPORT_FIRECLOUD_DIR}/bin/github-create-release \
        --repo-slug ${CI_REPO_SLUG} \
        --tag ${GIT_TAG} \
        --target $(git rev-parse HEAD) \
        --asset dist/app.zip \
        --asset snapshot.zip \
        --token ${GH_TOKEN}
}
```

**NOTE** The generation of the artifacts (e.g. the mentioned `dist/app.zip` and `snapshot.zip`)
happen via `make dist` which is [called by default in the `before_deploy`](../ci/before_deploy.inc.sh).


## `hotfix`

**NOTE** This section applies to repositories which you do **NOT** intend to use
as dependencies for other packages i.e. this section is for webapp repositories, not library repositories.

At times, we need to create hotfix releases for old versions.
That is, we deployed version `1.2.3` which needs a small fix, but internally we're working on version `2.3.4` already.

What we need is to branch off from the `1.2.3` version, make the small fix, and release.

But we cannot follow the normal release process e.g. via `make release/patch`, because there might already be a version `1.2.4`.

What we want is to create a `1.2.3-hotfix.1` release that doesn't overlap with any other version, and correctly signals that this is something in between `1.2.3` and `1.2.4`.

We do that by running `make release/vX.Y.Z-hotfix.N`,
where `X.Y.Z` is the current version and `hotfix.N` is an identifier and an index for the hotfix/custom release.

Here's an example

```
cd path/to/repo

git checkout -b small-fix-for-1.2.3 v1.2.3

# make changes

# save changes
git add
git commit -m "some changes"

# create a clean (nuked) build
# and bump the patch version
# and create a `git` tag via `npm version patch` e.g. v0.0.1
# and publish by pushing the v0.0.1 tag to the remote as is
make release/v.1.2.3-hotfix.1

# this is then picked up by Travis CI, which will then publish the artifacts as a github release
```

If you haven't done so already, please remember to merge your fixes to the `master` branch e.g. via `git cherry-pick`.
