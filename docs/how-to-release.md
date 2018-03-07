# How to release

Below you will find flows that focus on `npm` packages, but they are generic at core,
and they can be followed closely even for other type of packages.


## `npm` packages as `git` tags (libraries, frameworks, etc)

**NOTE** This section applies primarily, if not only, to packages which you intend to use
as dependencies for other packages i.e. not webapps.

In order to simplify the release process and not depend on `npm` registries,
we publish to the `git` repository thanks to [npm-publish-git](https://github.com/andreineculau/npm-publish-git).

If that sounds weird to you, it is not. `npm` had support for
git urls as dependencies](https://docs.npmjs.com/files/package.json#git-urls-as-dependencies)
for a long time.

The biggest counter-argument to `git` urls as dependencies is that
you end up checking out submodules, devDependecies, building, etc every time,
although you are only interested in the artifact.

And this is what `npm-publish-git` addresses.
What you end up having in a `git` tag is an exact match of what would be available on a `npm` registry,
so there are not `git` submodules to checkout, no devDependecies to install, no build process.
Read more in the [`npm-publish-git` README](https://github.com/andreineculau/npm-publish-git/blob/master/README.md).

An example flow for publishing [`minlog`](https://github.com/tobiipro/minlog)
which internally is using

* [repo/mk/js.common.node.mk](repo/mk/js.common.node.mk)
* [repo/mk/js.publish.npg.mk](repo/mk/js.publish.npg.mk)

```
cd path/to/minlog

# make changes

# save changes
git add
git commit -m "some changes"

# create a clean (nuked) build
# and bump the patch version and create a `git` tag via `npm version patch` e.g. v0.0.1
make nuke all test version

# publish by overwriting it (old v0.0.1 tag is renamed to v0.0.1-src)
make publish
```

From this point on, using `git://github.com/tobiipro/minlog.git#v0.0.1`
or `git://github.com/tobiipro/minlog.git#semver:0.0.1` is **exactly** the same
as if `minlog` would be published on the `npm` registry
and you would have used only `0.0.1` as a version specifier.


## `npm` packages as `github` artifacts

**NOTE** This section applies primarily to packages which you do **NOT** intend to use
as dependencies for other packages.

**NOTE** Since `npm` also supports installing from
[tarball URLs](https://docs.npmjs.com/files/package.json#urls-as-dependencies) it could work just as
fine for **public** `github` repositories to publish using `github` release artifacts,
but this may prove inferior as there is no semver version specifiers for tarball URLs as `npm` has for `git` URLs
e.g. `git://server/repo.git#semver:*` would take the latest semver version tag.

`github` releases support [attaching artifacts (or binaries)](https://help.github.com/articles/creating-releases/).

One could manually create a release, or create one automatically via the CI.

We have this working for a few private repositories, integrated with Travis CI.

An example flow which internally is using

* [repo/mk/js.common.node.mk](repo/mk/js.common.node.mk)
* [repo/mk/js.publish.tag.mk](repo/mk/js.publish.tag.mk)

```
cd path/to/repo

# make changes

# save changes
git add
git commit -m "some changes"

# create a clean (nuked) build
# and bump the patch version and create a `git` tag via `npm version patch` e.g. v0.0.1
# NOTE: <make nuke all> is not needed, but it's consistent with the npm-publish-git flow
make nuke all test version

# push the v0.0.1 tag to the remote
# this is then picked up by Travis CI, which will then publish the artifacts as a github release
make publish
```

Travis CI is then configured via `.travis.yml` with:

```yml
deploy:
  - provider: releases
    api_key:
      secure: ...
    file:
      - dist/app.zip
      - dist/changelog.txt
    skip_cleanup: true
    on:
      repo: tobiipro/repo
      tags: true
```

**NOTE** The generation of the artifacts via `make dist` will happen automatically,
if `.travis.yml` runs `./travis.sh before_deploy` in `before_deploy`
(default in the [`.travis.yml` template](../repo/dot.travis.yml); see [actual command](../repo/dot.travis.sh)).
