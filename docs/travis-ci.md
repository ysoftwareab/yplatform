# Travis CI

Hopefully you have some tests or just lint checks that you want to run
in a continuous manner, whenever new commits are pushed or on code from pull requests.

We currently use Travis CI and thus prefer it for consistency, but other CIs are ok given reasonable consideration.

If the repository is public, go to https://travis-ci.org/profile/tobiipro
and enable Travis CI integration for your repository.

If the repository is private, go to https://travis-ci.com/profile/tobiipro (.com instead of .org)
and enable Travis CI integration for your repository.

**NOTE** It is recommended that on the repository's Travis CI settings page you
* enable `Build only if .travis.yml is present`
* enable `Auto cancel branch builds`
* enable `Auto cancel pull request builds`
* add cronjob `master - daily - Always run`

Link to the repository's page on Travis CI
and embed a status image for the `master` branch (or more) in `README.md`, in short add:

```md
# <software product> [![Build Status][2]][1]

...

  [1]: https://travis-ci.org/tobiipro/<repo>
  [2]: https://travis-ci.org/tobiipro/<repo>.svg?branch=master
```

**NOTE** for private repositories, use `travis-ci.com` and you'll want to go https://travis-ci.com/tobiipro/<repo>,
click the status image, select 'Image URL' and copy the SVG URL (the link has a unique token).

Reference: https://docs.travis-ci.com/user/status-images/

Don't forget to commit the most important thing: a `.travis.yml` ([template](../repo/dot.travis.yml)) file which configures your Travis CI build.


## Secrets

**NOTE** See related docs on [how to manage secrets](how-to-manage-secrets.md).

If you have Travis-specific values to encrypt e.g. a Slack API token for notifications,
then you can add encrypted values in the `.travis.yml` file that only Travis CI can decrypt.

**NOTE** If you're working with **public repositories**, you can simply use the `travis-encrypt` utility in the `support-firecloud` repository and shortcircuit the official [`Travis CI` client](https://github.com/travis-ci/travis.rb) which requires Ruby&co. Use `support-firecloud/bin/travis-encrypt --value "..."` instead of `travis encrypt "..."` in the examples below.

For **private repositories**, you need to use the official (and Ruby heavy) [Travis CI client](https://github.com/travis-ci/travis.rb). On OSX run `brew install travis` to install it.

```shell
travis encrypt something_super_secret
```

Now you can add the `secret: "..."` text to your `.travis.yml` file.

For more info, see:
* https://docs.travis-ci.com/user/encryption-keys/
* https://docs.travis-ci.com/user/best-practices-security/

### `transcrypt`-ed repository

If your repository is `transcrypt`-ed, and you want to access the secrets in Travis CI, then follow these steps:

```shell
cd path/to/repo
travis encrypt "TRANSCRYPT_PASSWORD=<password>"
```

Now you can add this to your `.travis.yml` file:

```yaml
env:
  global:
    - secure: "..." # TRANSCRYPT_PASSWORD
```

**NOTE** The decryption of the repository will happen automatically in non-pull-request builds,
if `.travis.yml` runs `./travis.sh before_install` in `before_install`
(default in the [`.travis.yml` template](../repo/dot.travis.yml); see [actual command](../repo/dot.travis.sh)).


## Releases

If you are planning to do release via Travis CI, see [how to release](how-to-release.md).
