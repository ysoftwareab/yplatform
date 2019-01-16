# Travis CI

Hopefully you have some tests or just lint checks that you want to run
in a continuous manner, whenever new commits are pushed or on code from pull requests.

We currently use Travis CI and thus prefer it for consistency, but other CIs are ok given reasonable consideration.

Go to https://travis-ci.com/profile/tobiipro
and enable Travis CI integration for your repository.

**NOTE** It is recommended that on the repository's Travis CI settings page you
* enable `Build only if .travis.yml is present`
* **if you have long-running builds such as deployment to AWS CloudFormation**,
  enable `Limit concurrent jobs: 1`
* enable `Auto cancel branch builds`
* enable `Auto cancel pull request builds`
* add cronjob `master - daily - Always run`

Link to the repository's page on Travis CI
and embed a status image for the `master` branch (or more) in `README.md`, in short add:

```md
# <software product> [![Build Status][2]][1]

...

  [1]: https://travis-ci.com/tobiipro/<repo>
  [2]: https://travis-ci.com/tobiipro/<repo>.svg?branch=master
```

**NOTE** for private repositories, you'll want to go https://travis-ci.com/tobiipro/<repo>,
click the status image, select 'Image URL' and copy the SVG URL (the link has a unique token).

Reference: https://docs.travis-ci.com/user/status-images/

Don't forget to commit the most important thing: a `.travis.yml` ([template](../repo/dot.travis.yml)) file which configures your Travis CI build.


## Artifafcts

If your job has artifacts, like logs that you'd like to access outside of the Travis CI job log,
then you need to create a `.gitignore.jobs` file resembling a regular `.gitignore` that defines
which files should be ignored, while rest would be considered artifacts e.g.

```
# Ignore everything
*

# But not
!/some.log
```

Once you do, your artifacts would start being upload to `s3://infra-tobiicloud-com-eu-west-1/jobs/<job_id>/`.
If you'd like them uploaded elsewhere, add an environment variable `SF_JOBS_S3_PATH` in `.travis.yml`.
You can later browse them via AWS S3's UI or checking them out via
`aws s3 cp --recursive ${SF_JOBS_S3_PATH}/<job_id> ./`

If your `.travis.yml` also has a `GH_TOKEN` (a Github API token)
with enough permissions to push back to your repository,
then your artifacts would also be uploaded to a `refs/jobs/<job_id>` git ref,
making it possible to browse the artifacts via Github's UI,
or checking them out via `git fetch refs/jobs/<job_id> && git log -p FETCH_HEAD`
(or even `git checkout FETCH_HEAD`) from a local repo.


## Debugging

If you experience failures and you want to debug inside a Travis worker,
see [how to debug](https://docs.travis-ci.com/user/running-build-in-debug-mode/).

You can speed up the process, by running `support-firecloud/bin/travis-debug --token X --job Y`, where
- X is the token that you see at https://travis-ci.com/profile/
  - you can omit `--token X` if you have an environment variable `TRAVIS_API_TOKEN`
- Y can be a numeric job ID or a job URL or even a build URL (most useful)

**NOTE** Remember that you can almost always run `--help`,
so `support-firecloud/bin/travis-debug --help`, to get proper info.

Once you SSH via the tmate session, you will be welcomed by the message:

>   Run individual commands; or execute configured build phases
>   with `travis_run_*` functions (e.g., `travis_run_before_install`).

So run `travis_run_before_install` in order to bootstrap the machine.
Once that command finishes, you will be welcome by the message:

>   Please run `./.travis.sh debug` to activate your debug session !!!

So run `./.travis.sh debug` in order to setup the shell session (e.g. environment variables like `PATH`).

**NOTE** If `travis_run_before_install` fails and crashes the tmate session, you can try running `./.travis.sh before-install` (equivalent but safer).


## Secrets

**NOTE** See related docs on [how to manage secrets](how-to-manage-secrets.md).

If you have Travis-specific values to encrypt e.g. a Slack API token for notifications,
then you can add encrypted values in the `.travis.yml` file that only Travis CI can decrypt.

**NOTE** If you're working with **public repositories**,
you can simply use the `travis-encrypt` utility in the `support-firecloud` repository
and shortcircuit the official [`Travis CI` client](https://github.com/travis-ci/travis.rb) which requires Ruby&co.
Use `support-firecloud/bin/travis-encrypt --value "..."` instead of `travis encrypt "..."` in the examples below.

For **private repositories**, you need to use the official (and Ruby heavy) [Travis CI client](https://github.com/travis-ci/travis.rb). On OSX run `brew install travis` to install it.

```shell
travis encrypt --com something_super_secret
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
    # TRANSCRYPT_PASSWORD
    - secure: "..."
```

**NOTE** The decryption of the repository will happen automatically in non-pull-request builds,
if `.travis.yml` runs `./travis.sh before_install` in `before_install`
(default in the [`.travis.yml` template](../repo/dot.travis.yml); see [actual command](../repo/dot.travis.sh)).


## Notifications

### Slack

* Go to https://tobii.slack.com/apps/, find "Travis CI" and there existing integration between Travis and Tobii Slack
* Click "pencil" button ("Edit configuration") and note `<token>`
* Open terminal in the repo folder
* Generate new Travis secret as mentioned in [Secrets](#Secrets).
Assuming that you want notifications in #atex-ci channel command will look like:
  * in a case of public repo `support-firecloud/bin/travis-encrypt "tobii:<token>#atex-ci"`
  * in a case of private repo `travis encrypt "tobii:<token>#atex-ci"` (you will need to run `travis login --pro` before that)
* Add secret in the `.travis.yml` and configure other options
```yaml
notifications:
  email: true
  slack:
    rooms:
      # atex-ci
      - secure: "<your encrypted token here>"
    on_success: change
    on_pull_requests: false
```


## Releases

If you are planning to do release via Travis CI, see [how to release](how-to-release.md).
