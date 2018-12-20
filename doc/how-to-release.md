# How to release

Below you will find flows that focus on `npm` packages, but they are generic at core,
and they can be followed closely even for other type of packages.


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

* `make release/bugfix` will be `make release/patch` for both pre- and public versions
* `make release/feature` will be `make release/patch` for pre-, and `make release/minor` for public versions
* `make release/breaking` will be `make release/minor` for pre-, and `make release/major` for public versions
* `make release/public` will release `1.0.0`


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
# and bump the patch version
# and create a `git` tag via `npm version patch` e.g. v0.0.1
# and publish by overwriting it (old v0.0.1 tag is renamed to v0.0.1-src)
make release
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
# and bump the patch version
# and create a `git` tag via `npm version patch` e.g. v0.0.1
# and publish by pushing the v0.0.1 tag to the remote
make release

# this is then picked up by Travis CI, which will then publish the artifacts as a github release
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
