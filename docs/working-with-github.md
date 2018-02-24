# github

## Creating a new repository

[When creating a new repository](https://github.com/organizations/tobiipro/repositories/new),
it's recommended that you start with a private repository.
Once you push your commits, you and your team members can then inspect and verify
that everything looks ok, and only then make it public.

> There are only two hard things in Computer Science: cache invalidation and naming things. -- Phil Karlton
> https://martinfowler.com/bliki/TwoHardThings.html

Please name the repository appropriately, where appropriately stands for:
* descriptive and unique e.g. a real name, an accronym
  * a real name: [minlog](https://github.com/tobiipro/minlog)
  * an accronym: [KATT](https://github.com/for-GET/katt)
* if not unique then prefixed or suffixed with team name and mentioning software ecosystem
  * prefixed: firecloud-dashboard
  * suffixed: [support-firecloud](https://github.com/tobiipro/support-firecloud)
  * mentioning software ecosystem: [eslint-config-firecloud](https://github.com/tobiipro/eslint-config-firecloud)

A description is optional by Github standards, but we require it.

No need to initialize a repo with a `README.md`, nor add a `.gitignore` or a `LICENSE`.
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


### License

Before making your repository public, you must choose a license.
[Why?](https://blog.codinghorror.com/pick-a-license-any-license/)

#### Apache-2.0

By default, the approved license is ["Apache-2.0"](https://www.apache.org/licenses/LICENSE-2.0).
[Why?](https://choosealicense.com/licenses/apache-2.0/)

A `NOTICE` file needs to be added along the `LICENSE` file:

```
<software product>
Copyright <YYYY>- Tobii AB
Copyright <YYYY>- AUTHORS

This product includes software developed by
Tobii AB (https://www.tobii.com)
```

It is good practice to have an `AUTHORS` file also, in the format:

```
Full Name <email@example.com>
```

Commit the `LICENSE`, the `NOTICE` and possibly the `AUTHORS` file to your repo,
and link to the license in `README.md` by adding at the bottom:

```markdown
## License

[Apache-2.0](LICENSE)
```

**NOTE** Don't forget to mention the `Apache-2.0` license in whatever package manager you use e.g. `package.json`.

#### Unlicense

If the repo is really slim e.g. configuration, and thus there's nothing to protect/attribute,
then put the repo in the public domain by using ["Unlicense"](https://unlicense.org/).
[Why?](https://choosealicense.com/licenses/unlicense/)

Commit the `UNLICENSE` (not `LICENSE`) file to your repo,
and link to the license in `README.md` by adding at the bottom:

```md
## License

[Unlicense](UNLICENSE)
```

**NOTE** Don't forget to mention the `Apache-2.0` license in whatever package manager you use e.g. `package.json`.


### Enable Travis CI

Hopefully you have some tests or just lint checks that you want to run
in a continuous manner, whenever new commits are pushed or on code from pull requests.

We currently use Travis CI and thus prefer it for consistency, but other CIs are ok given reasonable consideration.

If the repo is public, go to https://travis-ci.org/profile/tobiipro
and enable Travis CI integration for your repo.

If the repo is private, go to https://travis-ci.com/profile/tobiipro (.com instead of .org)
and enable Travis CI integration for your repo.

Link to the repo's page on Travis CI
and embed a status image for the `master` branch (or more) in `README.md`, in short add:

```md
# <software product> [![Build Status][2]][1]

... CONTENT GOES HERE ...

## License

[Apache 2.0](LICENSE)


  [1]: https://travis-ci.org/tobiipro/<repo>
  [2]: https://travis-ci.org/tobiipro/<repo>.svg?branch=master
```

**NOTE** for private repos, use `travis-ci.com` and you'll want to go https://travis-ci.com/tobiipro/<repo>,
click the status image, select 'Image URL' and copy the SVG URL (the link has a unique token).

Reference: https://docs.travis-ci.com/user/status-images/

Don't forget to commit the most important thing: a `.travis.yml` file which configures your Travis CI build.

See how the `support-firecloud`'s [.travis.yml](../ci/travis.yml) looks like.
